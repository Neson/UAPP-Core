json.(@user, :id, :name, :mobile_verified)
json.(@user, :admission_year, :college_code, :college_name, :department_code, :department_name) if @data.include?('school_data')
