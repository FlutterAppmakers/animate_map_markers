package fr.mgen.mgen.recette

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Matrix
import android.graphics.Paint
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.app/markers"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "scaleMarker") {
                try {
                    // Get scale factor from Flutter
                    // Get the image bytes sent from Flutter
                    val imageBytes: ByteArray = call.argument<ByteArray>("image") ?: ByteArray(0)
                    val width = call.argument<Double>("width")?.toInt() ?: 100
                    val height = call.argument<Double>("height")?.toInt() ?: 100

                    // Decode the byte array into a Bitmap
                    val options = BitmapFactory.Options()
                    options.inScaled = false
                    val bitmap =
                        BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size, options)

                    // Scale the bitmap with provided width and height
                    val scaledBitmap = Bitmap.createScaledBitmap(
                        bitmap,
                        width,
                        height,
                        false
                    )

                    // Convert to byte array to send to Flutter
                    val stream = ByteArrayOutputStream()
                    scaledBitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                    val byteArray = stream.toByteArray()

                    result.success(byteArray) // Return the byte array to Flutter
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Failed to scale marker", null)
                }
            } else {
                result.notImplemented()
            }
        }

    }
}