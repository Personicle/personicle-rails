class AnalysisController < ApplicationController
    require 'json'
    require 'ostruct'
    require 'date'
    require 'csv'
    before_action :require_user, :session_active?

    def index
        
        puts params
        if(params.has_key?(:selected_analysis_id))
            puts "Selected Analysis ID found in Parameters"
            puts params[:selected_analysis_id]
        else
            puts "Not found"
        end

        @user_metadata = get_metadata()
        if @user_metadata.has_key? "status" && @user_metadata["status"] == "unauthorized"
            @user_metadata = {}
        end

        @response = JSON.parse(File.read('db/scatterplot_e2d.json'))
        # puts @response
        # puts @response['correlation_result']["0"]
        # puts @response['correlation_result']["0"]['data']
        
        @xarray = []
        @yarray = []
        @response['correlation_result']["2"]['data'].each {|x|
            # Push x and y values into seperate xarray and yarray
            @xarray.push(x[0])
            @yarray.push(x[1])
           
        }

        # If xarray or yarray is empty, no data to plot
        # Calculate upper and lower ranges
        # Plot all values inside this range and don't plot any outside the range 
        if @xarray.empty? || @yarray.empty? 
            puts "X Array or Y Array are Empty"
        else
            puts "Lower Range X"
            range_lower_x = percentile(@xarray, 0.025)
            puts range_lower_x
            puts "Upper Range X - 97th Percentile"
            range_upper_x = percentile(@xarray, 0.975)
            puts range_upper_x

            puts "Lower Range Y"
            range_lower_y = percentile(@yarray, 0.025)
            puts range_lower_y
            puts "Upper Range Y"
            range_upper_y = percentile(@yarray, 0.975)
            puts range_upper_y

            save_index_x = []
            save_index_y = []
            combined_index = []
            puts "Find x and index"
            @xarray.each_with_index do | x, index |
                if (x > range_upper_x || x < range_lower_x)
                    # puts "#{x} is number #{index} in the array"
                    # puts "Index: #{index} and Value #{@xarray[index]} Rejected"
                else
                    # Store list of indices we want to select
                    save_index_x.push(index)
                end
            end
                
            @yarray.each_with_index do | y, index |
                if (@yarray[index] > range_upper_y || @yarray[index] < range_lower_y)
                    # puts "#{y} is number #{index} in the array"
                # Use index to access corresponding y value in array
                    # puts "#{@yarray[index]} is number #{index} in the array"
                    # puts "Index: #{index} and Value #{@yarray[index]} Rejected"
                else
                    save_index_y.push(index)
                end
                # @xarray.reject {|x| x > range_upper_x || x < range_lower_x }
                    # if @xarray.select! {|x| x > range_upper_x || x < range_lower_x } # XArray containing only values in range        
            end 


            puts "Combined Indices"
            combined_index = save_index_x.intersection(save_index_y)
            # puts combined_index

        end

        # Populate filtered values with array of (x,y) values
        filtered_values = []
        for i in combined_index
            # puts "combined"
            # puts i
            filtered_values.push([@xarray[i],@yarray[i]])
        end

        puts "Filtered Values"
        # puts filtered_values
          
        # Push filtered_values into @response which will be fed to the view
        @response['correlation_result']["2"]["data"].replace(filtered_values)
        # puts "Response After Anomaly Removal - Replacing Data with Filtered Values in Position 2"
        # puts @response

        # Make view expect only data from one user
        @send =  @response['correlation_result']["2"]

        # Query User Created Analysis for Test User
        @user_created_analyses = UserCreatedAnalysis.where("user_id = '#{session[:oktastate]["uid"]}'")
        @user_created_analyses.each do |analysis|
            puts "User ID Loop"
            # puts analysis.user_id

            puts "Unique Analysis ID"
            # puts analysis.unique_analysis_id

            puts "Anchor"
            # puts analysis.anchor

            puts "Antecedent Name Loop"
            # puts analysis.antecedent_name
        end
    end
    def get_metadata
        begin
            # get user events metadata for the user id in the request
            event_metadata = JSON.parse(RestClient::Request.execute(:url => ENV["METADATA_HOST_EVENT"], headers: {Authorization: "Bearer #{session[:oktastate]['credentials']['token']} "}, :method => :get,:verify_ssl => false ),object_class: OpenStruct)
            puts event_metadata
 
            # Accumulate the parameters metadata from different sources in one row
            return_event_metadata = {}
            event_metadata.each do |datum| 
               if return_event_metadata.has_key? datum.event_type then 
                 current_object = return_event_metadata[datum.event_type]
               else
                 current_object = {
                     "type" => "event",
                     "parameters" => []
                 }
               end
               datum_parameters = JSON.parse datum.observed_parameters
               datum_parameters.each do |param, count|
                   unless current_object["parameters"].include?(param)
                      current_object["parameters"] << param
                   end
                end
               return_event_metadata[datum.event_type] = current_object
            end

            puts "Antedent Table"
            # puts analysis.antecedent_table
            datastream_metadata = JSON.parse(RestClient::Request.execute(:url => ENV["METADATA_HOST_DATASTREAM"], headers: {Authorization: "Bearer #{session[:oktastate]['credentials']['token']} "}, :method => :get,:verify_ssl => false ),object_class: OpenStruct)
            puts datastream_metadata

            puts "Antecedent Parameter"
            # puts analysis.antecedent_parameter
            datastream_metadata.each do |datum|
                stream_name = datum.datastream
                display_name = stream_name.split(".")[-1]
                unless stream_name.include? "subjective" 
                    puts stream_name
                    puts display_name
                    unless return_event_metadata.has_key? display_name
                        return_event_metadata[display_name] = {"type" => "datastream"}
                    end
                end
            end
            puts "final metadata"
            puts return_event_metadata

            puts "Consequent Name"
            # puts analysis.consequent_name

            puts "Consequent Table"
            # puts analysis.consequent_table

            puts "Consequent Parameter"
            # puts analysis.consequent_parameter

            puts "Aggregate Function"
            # puts analysis.aggregate_function

            puts "Antecedent Type"
            # puts analysis.antecedent_type

            puts "Consequent Type"
            # puts analysis.consequent_type

            puts "Consequent Interval"
            # puts analysis.consequent_interval

            puts "Antecendent Interval"
            # puts analysis.antecedent_interval

            puts "Query Interval"
            # puts analysis.query_interval
            puts "--------------"
            return  return_event_metadata
            # Sample return packet
            # {
            #         "Sleep" => {
            #             "type" => "event",
            #             "parameters" => ["duration", "sleep_quality"]
            #             },
            #         "Running" => {
            #             "type" => "event",
            #             "parameters" => ["duration", "calories"]
            #         },
            #         "Steps" => {
            #             "type" => "datastream"
            #         },
            #         "Calories" => {
            #             "type" => "datastream"
            #         }
            #     }
            # return the events metadata in the required JSON format
        rescue => exception
            if exception.response.code == 401
                # return  render status: :unauthorized, json: { error: "Unauthorized. You are not authorized to access this resource." }
                return {"status" => "unauthorized", "error" => "Unauthorized. You are not authorized to access this resource."}
            end
        end
    end

    def percentile(values, percentile)
        values_sorted = values.sort
        k = (percentile*(values_sorted.length-1)+1).floor - 1
        f = (percentile*(values_sorted.length-1)+1).modulo(1)
        
        return values_sorted[k] + (f * (values_sorted[k+1] - values_sorted[k]))
    end

    def analysis
        @response = JSON.parse(File.read('db/scatterplot_e2d.json'))
        puts @response
    end

    def select_analysis  
        # Get Updated Event
        puts "Print Selected Analysis"
        selected = params[:selected]
        puts params[:selected].class
        puts selected

        # Pass selected analysis ID and make a call to main analysis page and pass as parameter
        redirect_to pages_analysis_path(refresh:"hard_refresh", selected_analysis_id: selected)
    end

    def add_analysis
        # add the passed analysis to user_created)_analysis model
        puts params
        puts session
        puts @user_metadata
        analysis = UserCreatedAnalysis.new do |u|
            u.user_id = "#{session[:oktastate]["uid"]}"
            puts u.user_id
            u.anchor = params["anchor-select"]
            u.antecedent_name = params["antecedentName"]
            u.antecedent_table = "test"
            u.antecedent_parameter = (params.key?("antecedent-parameter"))?params["antecedent-parameter"]:nil
            u.consequent_name = params["consequentName"]
            u.consequent_table = "test"
            u.consequent_parameter = (params.key?("consequent-parameter"))?params["consequent-parameter"]:nil
            u.aggregate_function = "SUM"
            u.antecedent_type = (params.key?("antecedent-parameter"))? "EVENT" : "DATASTREAM"#@user_metadata[params["antecedentName"]]
            u.consequent_type = (params.key?("consequent-parameter"))? "EVENT" : "DATASTREAM" #@user_metadata[params["consequentName"]]
            u.consequent_interval = (params.key?("consequent-window"))?params["consequent-window"]:nil
            u.antecedent_interval = (params.key?("antecedent-window"))?params["antecedent-window"]:nil
            u.query_interval = "(#{params["interval-start"]},#{params["interval-end"]},#{params["time-interval-unit"]})"
        end
        analysis.save
        redirect_to analysis_page_path
    end

    def delete_analysis
        puts params
        puts session
        puts @user_metadata

        puts "Print Selected Analysis"
        selected = params[:selected]
        puts selected

        if !selected.nil?
            analysis = UserCreatedAnalysis.delete(selected)
        end
        redirect_to analysis_page_path
    end
    
end