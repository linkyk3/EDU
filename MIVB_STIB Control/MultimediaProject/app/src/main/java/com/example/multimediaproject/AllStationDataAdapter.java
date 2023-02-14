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

public class AllStationDataAdapter extends BaseAdapter {
    private static final String TAG = "AllStationDataAdapter";
    private static final int DISTANCE_RADIUS = 500;

    Context context;
    private List<StationSample> stationData;
    private MainActivity mainActivity;

    public AllStationDataAdapter(Context context, List<StationSample> stationData, MainActivity mainActivity){
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
        view = inflater.inflate(R.layout.listview_all_station_data, parent, false);

        TextView TVstationName = (TextView) view.findViewById(R.id.TV_StationSampleName);
        ImageView IVstationControl = (ImageView) view.findViewById(R.id.IV_StationSampleControl);
        // Update List View -> only if station is nearby (< 500m)
        Log.d(TAG, "Setting List View Item: " + stationData.get(i).getStationName());
        Log.d(TAG, "Control Status of item: " + stationData.get(i).getControl());
        // Set TextViews
        TVstationName.setText(stationData.get(i).getStationName());
        // Set Imageview
        if(stationData.get(i).getControl()){
            // Control -> Warning
            IVstationControl.setImageResource(R.drawable.ic_round_warning_24);
        } else{
            // No Control -> Check
            IVstationControl.setImageResource(R.drawable.ic_check);
        }
        return view;
    }
}
