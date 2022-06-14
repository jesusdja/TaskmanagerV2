package com.app.tra_s4c

import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin
import com.example.flutter_app_restart.FlutterRestartPlugin
import io.github.ponnamkarthik.toast.fluttertoast.FlutterToastPlugin
import com.tekartik.sqflite.SqflitePlugin
import com.benjaminabel.vibration.VibrationPlugin
import net.touchcapture.qr.flutterqr.FlutterQrPlugin
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel


import com.app.tra_s4c.R;
import android.view.View
import android.widget.LinearLayout

//import com.github.rmtmckenzie.qrmobilevision.QrMobileVisionPlugin
//import io.flutter.plugin.common.EventChannel
//import android.os.Handler
//import java.util.*
//
//import com.azure.android.communication.calling.*
//import android.widget.Toast
//
//import android.content.Context
//import com.app.tra_s4c.R;
//
//
//import androidx.appcompat.app.AppCompatActivity;
//import androidx.core.app.ActivityCompat;
//
//import android.Manifest;
//import android.content.Intent
//import android.content.pm.PackageManager;
//import android.media.AudioManager;
//import android.os.Build
//import android.os.Bundle;
//import android.view.LayoutInflater
//import android.view.ViewGroup
//import android.widget.Button;
//import android.widget.EditText;
//import android.widget.LinearLayout
//import androidx.annotation.RequiresApi
//import androidx.fragment.app.Fragment
//import com.azure.android.communication.calling.CallState;
//import com.azure.android.communication.calling.CallingCommunicationException;
//import com.azure.android.communication.calling.CameraFacing;
//import com.azure.android.communication.calling.ParticipantsUpdatedListener;
//import com.azure.android.communication.calling.PropertyChangedEvent;
//import com.azure.android.communication.calling.PropertyChangedListener;
//import com.azure.android.communication.calling.VideoDeviceInfo;
//import com.azure.android.communication.common.CommunicationUserIdentifier;
//import com.azure.android.communication.common.CommunicationIdentifier;
//import com.azure.android.communication.common.CommunicationTokenCredential;
//import com.azure.android.communication.calling.CallAgent;
//import com.azure.android.communication.calling.CallClient;
//import com.azure.android.communication.calling.StartCallOptions;
//import com.azure.android.communication.calling.DeviceManager;
//import com.azure.android.communication.calling.VideoOptions;
//import com.azure.android.communication.calling.LocalVideoStream;
//import com.azure.android.communication.calling.VideoStreamRenderer;
//import com.azure.android.communication.calling.VideoStreamRendererView;
//import com.azure.android.communication.calling.CreateViewOptions;
//import com.azure.android.communication.calling.ScalingMode;
//import com.azure.android.communication.calling.IncomingCall;
//import com.azure.android.communication.calling.Call;
//import com.azure.android.communication.calling.AcceptCallOptions;
//import com.azure.android.communication.calling.ParticipantsUpdatedEvent;
//import com.azure.android.communication.calling.RemoteParticipant;
//import com.azure.android.communication.calling.RemoteVideoStream;
//import com.azure.android.communication.calling.RemoteVideoStreamsEvent;
//import com.azure.android.communication.calling.RendererListener;
//import com.google.gson.Gson
//
//
//import java.util.ArrayList;
//import java.util.HashMap;
//import java.util.concurrent.ExecutionException;
//import java.util.concurrent.Executors;
//import io.flutter.view.FlutterMain
//import io.flutter.embedding.android.FlutterView
//import io.flutter.embedding.engine.FlutterEngineCache
//import io.flutter.embedding.engine.dart.DartExecutor
//import io.flutter.plugin.common.MethodCall
//import java.io.Serializable




class MainActivity: FlutterActivity() {

    private val CHANNEL = "com.app.tra_s4c/callview"
    //var callAgent: CallAgent? = null
    //var deviceManager: DeviceManager? = null
    //var incomingCall2: IncomingCall? = null


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.getPlugins().add(SharedPreferencesPlugin())
        //flutterEngine.getPlugins().add(QrMobileVisionPlugin())
        flutterEngine.getPlugins().add(FlutterQrPlugin())
        flutterEngine.getPlugins().add(FlutterToastPlugin())
        flutterEngine.getPlugins().add(SqflitePlugin())
        flutterEngine.getPlugins().add(VibrationPlugin())
        flutterEngine.getPlugins().add(FlutterRestartPlugin())

        //CHANNEL PARA LLAMAR TOKEN
        //getAllPermissions()
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "setToken") {
                    showPreview();
                    //createAgent(call.argument("tokenTxt"))
                    result.success(call.argument("tokenTxt"));
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun showPreview() {
        setContentView(R.layout.activity_main)
    }

//    private fun getAllPermissions() {
//        val requiredPermissions = arrayOf(Manifest.permission.RECORD_AUDIO, Manifest.permission.CAMERA, Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_PHONE_STATE)
//        val permissionsToAskFor = ArrayList<String>()
//        for (permission in requiredPermissions) {
//            if (ActivityCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
//                permissionsToAskFor.add(permission)
//            }
//        }
//        if (permissionsToAskFor.isEmpty()) {
//            ActivityCompat.requestPermissions(this, permissionsToAskFor.toTypedArray(), 1)
//        }
//    }
//
//    private fun createAgent(token:String?) {
//        val context: Context = this.getApplicationContext()
//        try {
//            val credential = CommunicationTokenCredential(token)
//            val callClient = CallClient()
//            deviceManager = callClient.getDeviceManager(context).get()
//            callAgent = callClient.createCallAgent(getApplicationContext(), credential).get()
//            //Toast.makeText(context, "handleIncomingCall", Toast.LENGTH_SHORT).show()
//            println("ESPERANDO LLAMADA")
//            handleIncomingCall()
//        } catch (ex: Exception) {
//            Toast.makeText(context, "Failed to create call agent.", Toast.LENGTH_SHORT).show()
//        }
//    }
//
//    private fun handleIncomingCall() {
//        callAgent?.addOnIncomingCallListener { incomingCall ->
//            incomingCall2 = incomingCall
//            //Executors.newCachedThreadPool().submit(this::answerIncomingCall)
//            println("ENTRANDO UNA LLAMADA")
//
//            val intento1 = Intent(this, AcercaDe::class.java)
//            val strEmp = Gson().toJson(incomingCall2)
//            val strEmp1 = Gson().toJson(deviceManager)
//            intento1.putExtra("incomingCall", strEmp)
//            intento1.putExtra("deviceManager", strEmp1)
//            startActivity(intento1)
//            println("ENVIADO EL STREAM2")
//        }
//    }
}

