package com.example.multimediaproject;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.AttachedSurfaceControl;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.ListView;

import java.util.List;


public class AllStationsActivity extends AppCompatActivity {
    private static final String TAG = "AllStationsActivity";
    float x1,y1,x2,y2;
    private List<StationSample> stationData;
    private MainActivity mainActivity = new MainActivity();
    private Button btnCallActivity;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_all_stations);

        // Retrieve station data from intent
        Intent intent = getIntent();
        stationData = (List<StationSample>) intent.getSerializableExtra("stationData");

        Log.d(TAG, "Setting All Stations List View...");
        ListView allStationsDataListView = (ListView) findViewById(R.id.LV_allStationData);
        AllStationDataAdapter allStationsDataAdapter = new AllStationDataAdapter(this, stationData, mainActivity);
        allStationsDataListView.setAdapter(allStationsDataAdapter);
        allStationsDataAdapter.notifyDataSetChanged();
        btnCallActivity = (Button) findViewById(R.id.btnGoRight2);
        btnCallActivity.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                openMain();
            }
        });
    }

    public void openMain(){
        Intent i = new Intent(AllStationsActivity.this, MainActivity.class);
        startActivity(i);
    }
    public boolean onTouchEvent(MotionEvent touchEvent){
        switch(touchEvent.getAction()){
            case MotionEvent.ACTION_DOWN:
                x1 = touchEvent.getX();
                y1 = touchEvent.getY();
                break;
            case MotionEvent.ACTION_UP:
                x2 = touchEvent.getX();
                y2 = touchEvent.getY();
                if(x1 >  x2){
                    Intent i = new Intent(AllStationsActivity.this, MainActivity.class);
                    startActivity(i);
                }
                break;
        }
        return false;
    }
}