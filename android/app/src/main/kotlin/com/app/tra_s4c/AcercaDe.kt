package com.app.tra_s4c

//import android.content.Context
//import android.os.Build
//import android.os.Bundle
//import android.view.View
//import android.widget.Button
//import android.widget.LinearLayout
//import java.util.concurrent.ExecutionException
//
//
//import io.flutter.embedding.android.FlutterActivity
//import androidx.annotation.NonNull
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin
//import com.github.rmtmckenzie.qrmobilevision.QrMobileVisionPlugin
//import io.github.ponnamkarthik.toast.fluttertoast.FlutterToastPlugin
//import com.tekartik.sqflite.SqflitePlugin
//import com.benjaminabel.vibration.VibrationPlugin
//
//import com.azure.android.communication.calling.*
//
//import io.flutter.plugins.GeneratedPluginRegistrant
//import io.flutter.plugin.common.MethodChannel
//
//import io.flutter.plugin.common.EventChannel
//import android.os.Handler
//import java.util.*
//
//import android.widget.Toast
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
//import android.view.LayoutInflater
//import android.view.ViewGroup
//import android.widget.EditText;
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
//
//
//import java.util.ArrayList;
//import java.util.HashMap;
//import java.util.concurrent.Executors;
//import io.flutter.view.FlutterMain
//import io.flutter.embedding.android.FlutterView
//import io.flutter.embedding.engine.FlutterEngineCache
//import io.flutter.embedding.engine.dart.DartExecutor
//import io.flutter.plugin.common.MethodCall
//import com.app.tra_s4c.MainActivity
//import com.google.gson.Gson
//import com.google.gson.reflect.TypeToken
//import java.lang.reflect.Type

class AcercaDe {
//class AcercaDe : AppCompatActivity() {


//    var deviceManager: DeviceManager? = null
//    var incomingCall2: IncomingCall? = null
//    var currentVideoStream: LocalVideoStream? = null
//    var previewRenderer: VideoStreamRenderer? = null
//    var preview: VideoStreamRendererView? = null
//    var call: Call? = null
//    private var remoteParticipantUpdatedListener: ParticipantsUpdatedListener? = null
//    private var onStateChangedListener: PropertyChangedListener? = null
//    private val renderRemoteVideo = true
//    private val streamData: Map<Int, StreamData> = HashMap()
//
//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        println("llega")
//        val bundle = intent.extras
//        val empStr = bundle!!.getString("incomingCall")
//        val empStr1 = bundle.getString("deviceManager")
//        val gson = Gson()
//        val type: Type = object : TypeToken<IncomingCall?>() {}.getType()
//        val type1: Type = object : TypeToken<DeviceManager?>() {}.getType()
//        val selectedEmp: IncomingCall = gson.fromJson(empStr, type)
//        val selectedEmp1: DeviceManager = gson.fromJson(empStr1, type1)
//        setContentView(R.layout.activity_main)
//
//        println("onCreate onCreate onCreate")
//
////        val i = intent
////        val dene: IncomingCall? = i.getSerializableExtra("incomingCall2") as IncomingCall?
////
//        incomingCall2 = selectedEmp
//
//        val hangupButton = findViewById<Button>(R.id.hang_up)
//        hangupButton.setOnClickListener { l: View? -> hangUp() }
//
//        answerIncomingCall()
//
//    }
//
//    private fun answerIncomingCall() {
//        val context: Context = this.getApplicationContext()
//        val callClient = CallClient()
//        deviceManager = callClient.getDeviceManager(context).get()
//
//        try {
//            val context: Context = this.getApplicationContext()
//            if (incomingCall2 == null) { return }
//            val acceptCallOptions = AcceptCallOptions()
//            val cameras: kotlin.collections.List<VideoDeviceInfo>? = deviceManager?.cameras
//            if (cameras?.isEmpty() == false) {
//                val camera: VideoDeviceInfo = cameras[0]
//                currentVideoStream = LocalVideoStream(camera, context)
//                val videoStreams: Array<LocalVideoStream?> = arrayOfNulls<LocalVideoStream>(1)
//                videoStreams[0] = currentVideoStream
//                val videoOptions = VideoOptions(videoStreams)
//                acceptCallOptions.videoOptions = videoOptions
//                println("ENTRANDO A answerIncomingCall 14")
//                showPreview(this.currentVideoStream!!)
//                println("ENTRANDO A answerIncomingCall 15")
//            }
//            println("ENTRANDO A answerIncomingCall 16")
//            call = incomingCall2!!.accept(context, acceptCallOptions).get()
//            println("ENTRANDO A answerIncomingCall 17")
//            //Subcribe to events on updates of call state and remote participants
//            call!!.addOnRemoteParticipantsUpdatedListener(this::handleRemoteParticipantsUpdate)
//            call!!.addOnStateChangedListener(this::handleCallOnStateChanged)
//        } catch (e: InterruptedException) {
//            e.printStackTrace()
//            println("Error 1 : ${e.printStackTrace()}")
//        } catch (e: ExecutionException) {
//            e.printStackTrace()
//            println("Error 2 : ${e.printStackTrace()}")
//        }
//
//    }
//
//    private fun showPreview(stream: LocalVideoStream) {
//        previewRenderer = VideoStreamRenderer(stream, this)
//        val layout = findViewById<LinearLayout>(R.id.localvideocontainer)
//        preview = previewRenderer!!.createView(CreateViewOptions(ScalingMode.FIT))
//        runOnUiThread { layout.addView(preview) }
//    }
//
//    fun handleRemoteParticipantsUpdate(args: ParticipantsUpdatedEvent) {
//        val participantVideoContainer: LinearLayout = findViewById(R.id.remotevideocontainer)
//        handleAddedParticipants(args.getAddedParticipants(), participantVideoContainer)
//    }
//
//    private fun handleAddedParticipants(participants: List<RemoteParticipant>, participantVideoContainer: LinearLayout) {
//        for (remoteParticipant in participants) {
//            remoteParticipant.addOnVideoStreamsUpdatedListener { videoStreamsEventArgs -> videoStreamsUpdated(videoStreamsEventArgs) }
//        }
//    }
//
//    @RequiresApi(Build.VERSION_CODES.N)
//    private fun videoStreamsUpdated(videoStreamsEventArgs: RemoteVideoStreamsEvent) {
//        for (stream in videoStreamsEventArgs.addedRemoteVideoStreams) {
//            val data = StreamData(stream, null, null)
//            streamData.getOrDefault(stream.id, data)
//            if (renderRemoteVideo) {
//                startRenderingVideo(data)
//            }
//        }
//        for (stream in videoStreamsEventArgs.removedRemoteVideoStreams) {
//            stopRenderingVideo(stream)
//        }
//    }
//
//    private fun handleCallOnStateChanged(args: PropertyChangedEvent) {
//        if (call!!.state === CallState.CONNECTED) {
//            val participantVideoContainer: LinearLayout = findViewById(R.id.remotevideocontainer)
//            handleAddedParticipants(call!!.remoteParticipants, participantVideoContainer)
//        }
//        if (call!!.state === CallState.DISCONNECTED) {
//            previewRenderer?.dispose()
//        }
//    }
//
//    private fun startRenderingVideo(data: StreamData) {
//        if (data.renderer != null) {
//            return
//        }
//        val layout = findViewById<View>(R.id.remotevideocontainer) as LinearLayout
//        data.renderer = VideoStreamRenderer(data.stream, this)
//        data.renderer!!.addRendererListener(object : RendererListener {
//            override fun onFirstFrameRendered() {
//                val text = data.renderer!!.size.toString()
//                println("MainActivity, Video rendering at: $text")
//            }
//
//            override fun onRendererFailedToStart() {
//                val text = "Video failed to render"
//                println("MainActivity , $text")
//            }
//        })
//        data.rendererView = data.renderer!!.createView(CreateViewOptions(ScalingMode.FIT))
//        runOnUiThread { layout.addView(data.rendererView) }
//    }
//
//    fun stopRenderingVideo(stream: RemoteVideoStream) {
//        val data = streamData[stream.id]
//        if (data == null || data.renderer == null) {
//            return
//        }
//        runOnUiThread { (findViewById<View>(R.id.remotevideocontainer) as LinearLayout).removeAllViews() }
//        data.rendererView = null
//        // Dispose renderer
//        data.renderer!!.dispose()
//        data.renderer = null
//    }
//
//    private fun hangUp() {
//        try {
//            call!!.hangUp().get()
//        } catch (e: ExecutionException) {
//            e.printStackTrace()
//        } catch (e: InterruptedException) {
//            e.printStackTrace()
//        }
//        if (previewRenderer != null) {
//            previewRenderer!!.dispose()
//        }
//        finish()
//    }

}

//class StreamData(var stream: RemoteVideoStream, var renderer: VideoStreamRenderer?, var rendererView: VideoStreamRendererView?)