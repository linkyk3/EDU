package com.example.multimediaproject;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;


import java.util.List;

public class MainStationDataAdapter extends BaseAdapter {
    private static final String TAG = "MainStationDataAdapter";
    private static final int DISTANCE_RADIUS = 500;

    Context context;
    private List<StationSample> stationData;
    private MainActivity mainActivity;

    public MainStationDataAdapter(Context context, List<StationSample> stationData, MainActivity mainActivity){
        super();
        this.context = context;
        this.stationData = stationData;
        this.mainActivity = mainActivity;
    }
    @Override
    public int getCount() {return stationData.size(); }

    @Override
    public Object getItem(int i) {
        return i;
    }

    @Override
    public long getItemId(int i) {
        return i;
    }

    @Override
    public boolean areAllItemsEnabled(){
        return false;
    }
    @Override
    public boolean isEnabled(int i) {
        return (stationData.get(i).getDistance() < DISTANCE_RADIUS);
    }

    @Override
    public View getView(int i, View view, ViewGroup parent) {
        LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        view = inflater.inflate(R.layout.listview_main_station_data, parent, false);

        TextView TVstationName = (TextView) view.findViewById(R.id.TV_StationSampleName);
        TextView TVstationDistance = (TextView) view.findViewById(R.id.TV_StationSampleDistance);
        ImageView IVstationControl = (ImageView) view.findViewById(R.id.IV_StationSampleControl);
        Button btnYes = (Button) view.findViewById(R.id.btnYes);
        Button btnNo = (Button) view.findViewById(R.id.btnNo);
        // Update List View -> only if station is nearby (< 500m)
        Log.d(TAG, "Setting List View Item: " + stationData.get(i).getStationName());
        Log.d(TAG, "Distance of item: " + stationData.get(i).getDistance());
        Log.d(TAG, "Control Status of item: " + stationData.get(i).getControl());
        // Set TextViews
        TVstationName.setText(stationData.get(i).getStationName());
        TVstationDistance.setText(String.format("%.2f", stationData.get(i).getDistance()) + "m");
        // Set Imageview
        if(stationData.get(i).getControl()){
            // Control -> Warning
            IVstationControl.setImageResource(R.drawable.ic_round_warning_24);
            mainActivity.updateMapsFragment(); // also update the fragment
        } else{
            // No Control -> Check
            IVstationControl.setImageResource(R.drawable.ic_check);
        }
        // Button Listeners
        btnYes.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mainActivity.retrieveFromDatabase(new MainActivity.FirestoreCallback() {
                    @Override
                    public void onCallback(List<String> currentControlStationsDB) {
                        Log.d(TAG, "Call Back from Database: Done");
                        if(!currentControlStationsDB.contains(stationData.get(i).getStationName())){ // not yet in list
                            Log.d(TAG, "Station not yet in database, adding to Database: " + stationData.get(i).getStationName());
                            mainActivity.addToDatabase(mainActivity.currentControlStationDoc, stationData.get(i).getStationName());
                            stationData.get(i).setControl(true);
                        }
                        else {
                            Log.d(TAG, "Station already in database: " + stationData.get(i).getStationName());
                            stationData.get(i).setControl(true); // if not already set
                        }
                        mainActivity.updateMapsFragment();
                        mainActivity.updateMainLV();
                        // disable both buttons when one of them is pressed -> doesn't work yet because the listview is updated when buttons are clicked
                        btnYes.setEnabled(false);
                        btnNo.setEnabled(false);
                    }
                });
            }
        });
        // NO
        btnNo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mainActivity.retrieveFromDatabase(new MainActivity.FirestoreCallback() {
                    @Override
                    public void onCallback(List<String> currentControlStationsDB) {
                        // check if in database, if so -> remove
                        if(currentControlStationsDB.contains(stationData.get(i).getStationName())){
                            Log.d(TAG, "Removing from database: " + stationData.get(i).getStationName());
                            mainActivity.removeFromDatabase(stationData.get(i).getStationName());
                            stationData.get(i).setControl(false);
                        }
                        else{
                            Log.d(TAG, "Station not in database: " + stationData.get(i).getStationName());
                        }
                        mainActivity.updateMapsFragment();
                        mainActivity.updateMainLV();
                        // disable both buttons when one of them is pressed
                        btnYes.setEnabled(false);
                        btnNo.setEnabled(false);
                    }
                });
            }
        });

        return view;
    }
}
