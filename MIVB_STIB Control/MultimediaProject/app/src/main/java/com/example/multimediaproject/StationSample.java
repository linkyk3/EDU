package com.example.multimediaproject;

import java.io.Serializable;

public class StationSample implements Serializable {
    private String stationName;
    private double longitude;
    private double latitude;
    private double distance;
    private boolean control;

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public String getStationName() {
        return stationName;
    }

    public void setStationName(String stationName) {
        this.stationName = stationName;
    }

    public double getDistance(){
        return distance;
    }

    public void setDistance(double distance){
        this.distance = distance;
    }

    public void setControl(boolean isControl) {this.control = isControl;}

    public boolean getControl() {return control; }

    @Override
    public String toString() {
        return "NearbyStations{" +
                "longitude= " + longitude +
                ", latitude= " + latitude +
                ", station= " + stationName + '\'' +
                ", distance= " + distance +
                ", is Control?= " + control +
                '}';
    }
}
