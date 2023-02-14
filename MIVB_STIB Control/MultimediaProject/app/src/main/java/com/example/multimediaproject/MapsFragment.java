package com.example.multimediaproject;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.drawable.Drawable;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MapStyleOptions;
import com.google.android.gms.maps.model.MarkerOptions;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;


public class MapsFragment extends Fragment {
    private static final String TAG = "MapsFragment";
    private static final float DEFAULT_ZOOM = 15f;

    private GoogleMap gMap;
    private LatLng currentLatLng;
    private List<StationSample> stationData;
    private ImageView currentLocationIV;
    private double currentLongitude;
    private double currentLatitude;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Log.d(TAG, "Maps Created");
        updateMapData(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_maps, container, false);

        // Initialize map fragment
        SupportMapFragment supportMapFragment = (SupportMapFragment) getChildFragmentManager().findFragmentById(R.id.mapsFragment);

        // Async map
        supportMapFragment.getMapAsync(new OnMapReadyCallback() {
            @Override
            public void onMapReady(@NonNull GoogleMap googleMap) {
                gMap = googleMap;
                gMap.setMapStyle(MapStyleOptions.loadRawResourceStyle(getContext(), R.raw.empty_map_style));
                Log.d(TAG, "onMapReady: map is ready");

                if (gMap != null) {
                    gMap.clear();
                    if (ActivityCompat.checkSelfPermission(getContext(), Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(getContext(), Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                        return;
                    }
                    // Set ImageView
                    currentLocationIV = (ImageView) view.findViewById(R.id.ic_current_location);
                    // Own Location
                    gMap.setMyLocationEnabled(true);
                    gMap.getUiSettings().setMyLocationButtonEnabled(false);

                    // Move the camera to current location
                    moveCameraToCurrentLocation();

                    // Place the markers on the map
                    updateMarkers();

                    currentLocationIV.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            Log.d(TAG, "onCurrentLocationClick");
                            moveCameraToCurrentLocation();
                        }
                    });
                }
            }
        });
        return view;
    }

    private void moveCameraToCurrentLocation(){
        Log.d(TAG, "moveCamera: moving camera to current location...");
        gMap.moveCamera(CameraUpdateFactory.newLatLngZoom(currentLatLng, DEFAULT_ZOOM));
    }

    private BitmapDescriptor bitmapDescriptorFromVector(Context context, int vectorResId){
        Drawable vectorDrawable = ContextCompat.getDrawable(context, vectorResId);
        vectorDrawable.setBounds(0, 0, vectorDrawable.getIntrinsicWidth(), vectorDrawable.getIntrinsicHeight());
        Bitmap bitmap = Bitmap.createBitmap(vectorDrawable.getIntrinsicWidth(), vectorDrawable.getIntrinsicHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);
        vectorDrawable.draw(canvas);
        return BitmapDescriptorFactory.fromBitmap(bitmap);
    }

    public void updateMapData(boolean onCreate){
        currentLongitude = this.getArguments().getDouble("Current Longitude");
        currentLatitude = this.getArguments().getDouble("Current Latitude");
        Log.d(TAG, "Current Longitude: " + currentLongitude);
        Log.d(TAG, "Current Latitude: " + currentLatitude);
        // Parse to LatLng type
        currentLatLng = new LatLng(currentLatitude, currentLongitude);

        stationData = (List<StationSample>) this.getArguments().getSerializable("stationData");
        printControlStations();

        if(!onCreate){ // not the first launch
            updateMarkers();
        }
    }

    public void updateMarkers(){
        gMap.clear();
        Log.d(TAG, "Placing Makers");
        for(int i = 0; i < stationData.size(); i++){
            if(stationData.get(i).getControl()){ // control
                MarkerOptions markerOptions = new MarkerOptions();
                LatLng latLng = new LatLng(stationData.get(i).getLatitude(), stationData.get(i).getLongitude());
                markerOptions.position(latLng);
                markerOptions.title(stationData.get(i).getStationName());
                markerOptions.icon(bitmapDescriptorFromVector(getContext(), R.drawable.ic_round_warning_24));
                gMap.addMarker(markerOptions);
            } else{ // no control
                MarkerOptions markerOptions = new MarkerOptions();
                LatLng latLng = new LatLng(stationData.get(i).getLatitude(), stationData.get(i).getLongitude());
                markerOptions.position(latLng);
                markerOptions.title(stationData.get(i).getStationName());
                markerOptions.icon(bitmapDescriptorFromVector(getContext(), R.drawable.ic_outline_tram_24));
                gMap.addMarker(markerOptions);
            }
        }
    }

    private void printControlStations(){
        for(int i = 0; i < stationData.size(); i++){
            if(stationData.get(i).getControl()){
                Log.d(TAG, "Control Stations: " + stationData.get(i).getStationName());
            }
        }
    }

}