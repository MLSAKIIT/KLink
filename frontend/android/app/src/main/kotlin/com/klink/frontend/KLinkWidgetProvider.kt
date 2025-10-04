package com.klink.frontend

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import es.antonborri.home_widget.HomeWidgetPlugin
import java.net.URL
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class KLinkWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.klink_widget).apply {
                val widgetData = HomeWidgetPlugin.getData(context)
                val hasData = widgetData.getBoolean("hasData", false)

                if (hasData) {
                    val imageUrl = widgetData.getString("imageUrl", "") ?: ""
                    val username = widgetData.getString("username", "") ?: ""
                    val name = widgetData.getString("name", "") ?: ""
                    val content = widgetData.getString("content", "") ?: ""
                    val timestamp = widgetData.getString("timestamp", "") ?: ""

                    // Set text views
                    setTextViewText(R.id.widget_username, "@$username")
                    setTextViewText(R.id.widget_name, name)
                    setTextViewText(R.id.widget_content, content)
                    setTextViewText(R.id.widget_timestamp, timestamp)

                    // Load image asynchronously
                    if (imageUrl.isNotEmpty()) {
                        GlobalScope.launch {
                            try {
                                val bitmap = loadImageFromUrl(imageUrl)
                                withContext(Dispatchers.Main) {
                                    if (bitmap != null) {
                                        setImageViewBitmap(R.id.widget_image, bitmap)
                                        setViewVisibility(R.id.widget_image, android.view.View.VISIBLE)
                                        setViewVisibility(R.id.widget_no_image, android.view.View.GONE)
                                    }
                                }
                            } catch (e: Exception) {
                                e.printStackTrace()
                            }
                        }
                    }

                    setViewVisibility(R.id.widget_content_layout, android.view.View.VISIBLE)
                    setViewVisibility(R.id.widget_no_data, android.view.View.GONE)
                } else {
                    setViewVisibility(R.id.widget_content_layout, android.view.View.GONE)
                    setViewVisibility(R.id.widget_no_data, android.view.View.VISIBLE)
                    val message = widgetData.getString("message", "No posts available") ?: "No posts available"
                    setTextViewText(R.id.widget_no_data, message)
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private suspend fun loadImageFromUrl(imageUrl: String): Bitmap? = withContext(Dispatchers.IO) {
        try {
            val url = URL(imageUrl)
            BitmapFactory.decodeStream(url.openConnection().getInputStream())
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
}
