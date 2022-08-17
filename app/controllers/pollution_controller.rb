class PollutionController < ApplicationController
    require 'json'
    require 'ostruct'
    require 'date'
    before_action :require_user, :session_active?

    def index
       @exposome_streams = [
        "com.personicle.individual.datastreams.exposome.aqi",
        "com.personicle.individual.datastreams.exposome.no",
        "com.personicle.individual.datastreams.exposome.no2",
        "com.personicle.individual.datastreams.exposome.03",
        "com.personicle.individual.datastreams.exposome.so2",
        "com.personicle.individual.datastreams.exposome.pm2_5",
        "com.personicle.individual.datastreams.exposome.pm10",
        "com.personicle.individual.datastreams.exposome.nh3",
        "com.personicle.individual.datastreams.exposome.temp",
        "com.personicle.individual.datastreams.exposome.feels_like",
        "com.personicle.individual.datastreams.exposome.pressure",
        "com.personicle.individual.datastreams.exposome.humidity",
        "com.personicle.individual.datastreams.exposome.uvi"
       ]
    end

    def get_exposome_data
        required = [ :exposomeType]
        @exposome_streams = [
        "com.personicle.individual.datastreams.exposome.aqi",
        "com.personicle.individual.datastreams.exposome.no",
        "com.personicle.individual.datastreams.exposome.no2",
        "com.personicle.individual.datastreams.exposome.03",
        "com.personicle.individual.datastreams.exposome.so2",
        "com.personicle.individual.datastreams.exposome.pm2_5",
        "com.personicle.individual.datastreams.exposome.pm10",
        "com.personicle.individual.datastreams.exposome.nh3",
        "com.personicle.individual.datastreams.exposome.temp",
        "com.personicle.individual.datastreams.exposome.feels_like",
        "com.personicle.individual.datastreams.exposome.pressure",
        "com.personicle.individual.datastreams.exposome.humidity",
        "com.personicle.individual.datastreams.exposome.uvi"
       ]
      
        form_complete = true
        required.each do |k|
            if params.has_key?(k) and not params[k].blank?
            else
                form_complete = false
            end
        end
        puts params[:exposomeType]
        # Loop over array of exposomes and make request to API to get that data from the loop
        st = 3.months.ago.strftime("%Y-%m-%d %H:%M:%S.%6N")
        et = Time.now.strftime("%Y-%m-%d %H:%M:%S.%6N")

        exposome_type = params[:exposomeType]
    
        # For each call of this API, need to store this data in hash variable / hash object
        # @exposome_streams_hash = {}
        if form_complete
            if params.has_key?(:refresh) && params[:refresh]=="hard_refresh"
                @response = FetchData.get_datastreams(session,source="org.personicle.exposome",data_type=exposome_type,start_date=st, end_date=et, hard_refresh=true,uid=session[:oktastate]['uid'])
                # @exposome_streams_hash[exposome_type] = @response
                exposome_data = @response
                # -- all the views will be able to access that hash object, so when generating chart for temperature
                # can pass object specific for temperature
                # In chart, use time stamp and value fields to generate the chart. 
            else   
                @response = FetchData.get_datastreams(session,source="org.personicle.exposome",data_type=exposome_type,start_date=st, end_date=et, hard_refresh=false,uid=session[:oktastate]['uid'])
                # @exposome_streams_hash[exposome_type] = @response
                exposome_data = @response
            end

            puts exposome_data
            respond_to do |format|
                format.html {render :index, locals: { exposome_data: exposome_data, exposome_type: exposome_type } }
                # redirect_to pages_recipes_path, recipes: response.hits
            end
        else
            respond_to do |format|
                format.html {render :index, locals: { status_msg: "An error occured while fetching exposome data" } }
                # redirect_to pages_recipes_path, recipes: response.hits
            end
        end
    end
end
