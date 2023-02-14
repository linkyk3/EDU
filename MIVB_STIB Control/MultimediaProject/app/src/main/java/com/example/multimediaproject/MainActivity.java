package com.example.multimediaproject;

import androidx.appcompat.app.AppCompatActivity;

import androidx.core.app.ActivityCompat;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentTransaction;


import android.Manifest;
import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Build;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.ListView;

import android.util.Log;

import android.widget.Toast;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QuerySnapshot;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Serializable;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class MainActivity extends AppCompatActivity {
    //--- Macros ---//
    private static final String TAG = "MainActivity";
    public  static final int DEFAULT_UPDATE_INTERVAL = 30;
    public  static final int FAST_UPDATE_INTERVAL = 5;
    private static final int PERMISSION_FINE_LOCATION = 99;
    private static final int DISTANCE_RADIUS = 500;
    private static final int ERROR_DIALOG_REQUEST = 9001;


    //--- UI Elements ---//
    private Button btnCallActivity;
    float x1,y1,x2,y2;
    MapsFragment mapsFragment;

    //--- Location ---//
    // Config file for all settings related to FusedLocationProviderContent
    LocationRequest locationRequest;
    // Google API for location services
    FusedLocationProviderClient fusedLocationProviderClient;
    // Necessary for a function
    LocationCallback locationCallBack;
    // Location updater counter
    private int locationUpdateCounter = 0;
    // Current long and lat
    public double currentLongitude;
    public double currentLatitude;

    //--- Lists ---//
    private final List<StationSample> stationData = new ArrayList<>(); // list with all the stations and their attributes
    //--- List Views and Adapters ---//
    private ListView mainStationDataListView;
    private MainStationDataAdapter mainStationDataAdapter;

    //--- Firestone database ---//
    public FirebaseFirestore firestoreDB = FirebaseFirestore.getInstance(); // Firestore DB Instance
    public Map<String, Object> currentControlStationDoc = new HashMap<>(); // Firestore Object
    public String collectionName = "Current Control Stations"; // Firestore Collection Name
    public String document = "Station Name"; // Firestore document Name
    private final List<String> dataDB = new ArrayList<>(); // List that is returned from the database

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // GMaps services check
        isServicesOK();

        // Create new Maps Fragment Object
        mapsFragment = new MapsFragment();

        //---Location---//
        // Set all properties of LocationRequest
        locationRequest = new LocationRequest();
        locationRequest.setInterval(1000 * DEFAULT_UPDATE_INTERVAL);
        locationRequest.setFastestInterval(1000 * FAST_UPDATE_INTERVAL);
        locationRequest.setPriority(LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY);
        // Event that is triggered whenever the update interval is met
        locationCallBack = new LocationCallback() {
            @Override
            public void onLocationResult(@NonNull LocationResult locationResult) {
                super.onLocationResult(locationResult);
                // save the location
                //updateUI();
                updateGPS();
            }
        };

        // First call this function so that the locationRequest object is made an permission is checked
        updateGPS();

        // Start constant location update when app is launched
        locationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
        startLocationUpdates();

        // Initialize Stations Data List
        initStationData();

        //--- UI Elements ---//
        btnCallActivity = (Button) findViewById(R.id.btnReportControl);
        btnCallActivity.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                openReportControlActivity();
            }
        });
        btnCallActivity = (Button) findViewById(R.id.btnGoRight);
        btnCallActivity.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                openReportControlActivity();
            }
        });
        btnCallActivity = (Button) findViewById(R.id.btnGoLeft);
        btnCallActivity.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                openAllStationsActivity();
            }
        });

    }

    // Detect Returning from other activity to update the LV
    @Override
    protected void onResume(){
        super.onResume();
        Log.d(TAG, "On Resume");
        updateMainLV();
    }

    //--- Switch Activity Functions---//
    public void openReportControlActivity(){
        Intent intent = new Intent(this, ReportControlActivity.class);
        intent.putExtra("stationData", (Serializable) stationData); // pass station data to activity
        startActivity(intent);
    }

    public void openAllStationsActivity(){
        Intent intent = new Intent(this, AllStationsActivity.class);
        intent.putExtra("stationData", (Serializable) stationData);
        startActivity(intent);
    }

    //--- Touch Event Function ---//
    public boolean onTouchEvent(MotionEvent touchEvent){
        switch(touchEvent.getAction()){
            case MotionEvent.ACTION_DOWN:
                x1 = touchEvent.getX();
                y1 = touchEvent.getY();
                break;
            case MotionEvent.ACTION_UP:
                x2 = touchEvent.getX();
                y2 = touchEvent.getY();
                if(x1 <  x2){
                    Intent i = new Intent(MainActivity.this, AllStationsActivity.class);
                    startActivity(i);
                }else if(x1 >  x2){
                    Intent i = new Intent(MainActivity.this, ReportControlActivity.class);
                    startActivity(i);
                }
                break;
        }
        return false;
    }

    //--- Location/GPS Functions ---//
    private void startLocationUpdates() {
        Toast.makeText(getApplicationContext(), "Location is being tracked", Toast.LENGTH_SHORT).show();
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return;
        }
        fusedLocationProviderClient.requestLocationUpdates(locationRequest, locationCallBack, null);
        updateGPS();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        switch (requestCode) {
            case PERMISSION_FINE_LOCATION:
                if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    updateGPS();
                }
                else {
                    Toast.makeText(this, "This app requires permission to be granted in order to work properly", Toast.LENGTH_SHORT).show();
                    finish();
                }
        }
    }

    private void updateGPS() {
        // Get permissions from the user to track GPS
        // Get current location from the fused client
        // Update UI
        fusedLocationProviderClient = LocationServices.getFusedLocationProviderClient(MainActivity.this);
        // If permission is granted from the user
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
            // user provided the permission
            fusedLocationProviderClient.getLastLocation().addOnSuccessListener(this, new OnSuccessListener<Location>() {
                @Override
                public void onSuccess(Location location) {
                    locationUpdateCounter++;
                    Log.d(TAG, "Location Update Counter: " + locationUpdateCounter);
                    // Pass the current long and lat to corresponding vars
                    //currentLongitude = location.getLongitude();
                    //currentLatitude = location.getLatitude();
                    // Test Locations:
                    currentLongitude = 4.396682;
                    currentLatitude = 50.824280;
                    // Check nearby stations everytime location is updated
                    updateStationDistance(location);
                }
            });
        }
        else {
            // permission not granted yet
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) { // check OS version
                requestPermissions(new String[] {Manifest.permission.ACCESS_FINE_LOCATION}, PERMISSION_FINE_LOCATION);
            }
        }

    }

    //--- Google Maps Functions ---//
    public void isServicesOK(){
        Log.d(TAG, "isServicesOK: checking google services version...");
        int available = GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(MainActivity.this);

        if(available == ConnectionResult.SUCCESS){
            Log.d(TAG, "isServicesOK: Google Play Services is working");
        }
        else if(GoogleApiAvailability.getInstance().isUserResolvableError(available)){
            Log.d(TAG, "isServicesOK: an error occured but fixable");
            Dialog dialog = GoogleApiAvailability.getInstance().getErrorDialog(MainActivity.this, available, ERROR_DIALOG_REQUEST);
            dialog.show();
        }else{
            Toast.makeText(this, "You can't make map requests", Toast.LENGTH_SHORT).show();
        }
    }

    //--- UI Functions ---//
    // Update Station Data List View
    private void updateUI() {
        Log.d(TAG, "Updating UI...");
        // Update station data list view every x times the location updates
        // Calling DB takes time -> every time the location updates is to fast
        if(locationUpdateCounter == 1){ // on startup
            // GMaps fragment
            if(currentLatitude != 0.0 && currentLongitude != 0.0){
                Log.d(TAG, "First Launch: Creating bundle and launching fragment...");
                // First launch
                Bundle bundle = new Bundle();
                bundle.putDouble("Current Longitude", currentLongitude);
                bundle.putDouble("Current Latitude", currentLatitude);
                bundle.putSerializable("stationData", (Serializable) stationData);
                mapsFragment.setArguments(bundle);
                getSupportFragmentManager().beginTransaction().add(R.id.mapsContainer, mapsFragment).commit();
            }
            updateStationControls();
            updateMainLV();
        }
        if (locationUpdateCounter % 4 == 0){
            updateStationControls();
            updateMainLV();
            updateMapsFragment();
        }
    }

    // Updating the main listview
    public void updateMainLV(){
        Log.d(TAG, "Updating Main List View...");
        //printStationDataList();
        // Create new temp nearby station data list to pass it to the adapter -> otherwise all the other stops that are not nearby are also shown
        List<StationSample> nearbyStations = new ArrayList<>();
        for (int i = 0; i < stationData.size(); i++){
            if(stationData.get(i).getDistance() < DISTANCE_RADIUS){
                nearbyStations.add(stationData.get(i));
            }
        }
        mainStationDataListView = (ListView) findViewById(R.id.LV_stationData);
        mainStationDataAdapter = new MainStationDataAdapter(this, nearbyStations, MainActivity.this);
        mainStationDataListView.setAdapter(mainStationDataAdapter);
        mainStationDataAdapter.notifyDataSetChanged();
    }

    // Updates the maps fragment with new data
    public void updateMapsFragment(){
        Log.d(TAG, "Updating GMaps Fragment...");
        Bundle bundle = new Bundle();
        bundle.putDouble("Current Longitude", currentLongitude);
        bundle.putDouble("Current Latitude", currentLatitude);
        bundle.putSerializable("stationData", (Serializable) stationData);
        mapsFragment.getArguments().putAll(bundle);
        mapsFragment.updateMapData(false);
    }

    //--- Data Functions ---//
    // Initialize Stations Data List
    private void initStationData(){
        readStationData();
        for(int i = 0; i < stationData.size(); i++){
            stationData.get(i).setControl(false);
            stationData.get(i).setDistance(0);
        }
    }

    // Read CSV file and put into a list of created object
    private void readStationData() {
        InputStream inputStream = getResources().openRawResource(R.raw.stops_data);
        BufferedReader lineReader = new BufferedReader(
                new InputStreamReader(inputStream, StandardCharsets.UTF_8)
        );

        String line = "";
        int i = 0;
        try {
            while ((line = lineReader.readLine()) != null){
                // Skip header
                if(i == 0){
                    i++;
                    continue;
                }
                // Split by ';'
                String[] tokens = line.split(",");
                // Read the data
                StationSample stationSample = new StationSample();
                stationSample.setLatitude(Double.parseDouble(tokens[0]));
                stationSample.setLongitude(Double.parseDouble(tokens[1]));
                stationSample.setStationName(tokens[2]);
                stationData.add(stationSample);
                //Log.d(TAG, "Just created: " + stationSample.getStationName());
            }
        } catch (IOException e) {
            Log.wtf(TAG, "Error reading data file on line" + line, e);
            e.printStackTrace();
        }
    }

    //--- List Functions ---//
    // Update the distance of every stationSample in stationData -> relative to current location
    private void updateStationDistance(Location currentLocation){
        Log.d(TAG, "Updating Station Distance...");
        // Loop over List with station objects
        for (int i = 0; i < stationData.size(); i++){
            // Create Location object and add data from stationData List -> use build in .distanceTo function
            Location stationLocation = new Location(stationData.get(i).getStationName());
            stationLocation.setLatitude(stationData.get(i).getLatitude());
            stationLocation.setLongitude(stationData.get(i).getLongitude());
            currentLocation.setLatitude(currentLatitude); // current Latitude
            currentLocation.setLongitude(currentLongitude); // current Longitude
            // Calculate distance
            double distance = currentLocation.distanceTo(stationLocation);
            // Update distance in station data list
            stationData.get(i).setDistance(distance);
            //Log.d(TAG, "Distance: " + distance);
        }
        updateUI();
    }

    // Update the station data list with the database
    private void updateStationControls(){
        Log.d(TAG, "Updating Station Control Status...");
        retrieveFromDatabase(new FirestoreCallback() {
            @Override
            public void onCallback(List<String> currentControlStations) {
                for(int i = 0; i < stationData.size(); i++){
                    if(currentControlStations.contains(stationData.get(i).getStationName())){
                        stationData.get(i).setControl(true);
                        Log.d(TAG, "Control Stations: " + stationData.get(i).getStationName());
                    } else {
                        stationData.get(i).setControl(false);
                    }
                }
                updateMainLV();
            }
        });
    }

    //--- Firebase Functions ---//
    // Custom call back -> needed because the Listener functions work asynchronous
    public interface FirestoreCallback{
        void onCallback(List<String> currentControlStations);
    }
    // Context function
    private Context getContext(){
        return (Context)this;
    }
    // Add a station to the database
    public void addToDatabase(Map<String, Object> collection, String dataElement){
        collection.put(document, dataElement);
        firestoreDB.collection(collectionName).add(collection)
                .addOnSuccessListener(new OnSuccessListener<DocumentReference>() {
                    @Override
                    public void onSuccess(DocumentReference documentReference) {
                        Log.d(TAG, "Added to database: " + documentReference.getId());
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        Log.w(TAG, "Error adding to database", e);
                    }
                });
    }

    // Delete a specified item from the database -> already checked if in database
    public void removeFromDatabase(String dataElement){
        // first get the corresponding documentID to the dataElement
        firestoreDB.collection(collectionName)
                .whereEqualTo(document, dataElement)
                .get().addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                    @Override
                    public void onComplete(@NonNull Task<QuerySnapshot> task) {
                        if(task.isSuccessful() && !task.getResult().isEmpty()){
                            DocumentSnapshot documentSnapshot = task.getResult().getDocuments().get(0);
                            String documentID = documentSnapshot.getId();
                            // delete corresponding document
                            firestoreDB.collection(collectionName)
                                    .document(documentID)
                                    .delete()
                                    .addOnSuccessListener(new OnSuccessListener<Void>() {
                                        @Override
                                        public void onSuccess(Void unused) {
                                            Log.d(TAG, "Removed from database: " + documentID);
                                        }
                                    })
                                    .addOnFailureListener(new OnFailureListener() {
                                        @Override
                                        public void onFailure(@NonNull Exception e) {
                                            Log.d(TAG, "Error occurred when removing document");
                                        }
                                    });
                        }
                    }
                });
    }

    // Get all items from database corresponding to the document name (Station Name)
    public void retrieveFromDatabase(FirestoreCallback firestoreCallback){
        dataDB.clear();
        //boolean callBackDone = false;
        Log.d(TAG, "Retrieving latest list from database...");
        firestoreDB.collection(collectionName).get()
                .addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                    @Override
                    public void onComplete(@NonNull Task<QuerySnapshot> task) {
                        if (task.isSuccessful()){
                            for (DocumentSnapshot documentSnapshot : task.getResult()) {
                                String dataElement = documentSnapshot.getString(document);
                                dataDB.add(dataElement);
                            }
                            //printStringList(dataDB);
                            firestoreCallback.onCallback(dataDB);
                        }
                    }
                });
    }

    // --- Debug Functions --- //
    private void printStationDataList(){
        Log.d(TAG, "Printing Station Data List... ");
        for (int i = 0; i < stationData.size(); i++){
            Log.d(TAG, "In Station Data List: " + stationData.get(i).getStationName());
            Log.d(TAG, "with distance: " + stationData.get(i).getDistance());
        }
    }

    private void printStringList(List<String> stationList){
        Log.d(TAG, "Printing String List... ");
        for (int i = 0; i < stationList.size(); i++){
            Log.d(TAG, "Station in List: " + stationList.get(i));
        }
    }
}

