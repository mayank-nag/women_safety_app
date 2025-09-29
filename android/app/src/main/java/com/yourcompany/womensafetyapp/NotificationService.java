package com.example.safetyapp;

import android.service.notification.NotificationListenerService;
import android.service.notification.StatusBarNotification;
import android.os.Bundle;
import android.content.Intent;
import android.util.Log;

public class NotificationService extends NotificationListenerService {

    @Override
    public void onNotificationPosted(StatusBarNotification sbn) {
        if (sbn.getPackageName().equals("com.whatsapp")) {
            Bundle extras = sbn.getNotification().extras;
            String title = extras.getString("android.title"); // sender
            String text = extras.getCharSequence("android.text").toString(); // message

            Log.d("WHATSAPP_NOTIF", title + ": " + text);

            // 👉 Send this data to Flutter via Broadcast
            Intent intent = new Intent("WA_MESSAGE");
            intent.putExtra("sender", title);
            intent.putExtra("message", text);
            sendBroadcast(intent);
        }
    }
}
