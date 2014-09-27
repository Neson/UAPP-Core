class PagesController < ApplicationController
  before_filter :set_access_control_allow_headers, only: [:api_docs, :api_docs_json, :api_doc_json]

  def api_docs
  end

  def api_docs_json
    data = JSON.parse( IO.read('public/swagger_docs/api-docs.json') )
    data['basePath'] = Setting.app_url
    data['apis'].each { |api| api['path'] = 'api-docs/' + api['path'] }
    render :json => data
  end

  def api_doc_json
    data = JSON.parse( IO.read("public/swagger_docs/api/#{params['v'].tr('^A-Za-z0-9', '')}/#{params['name'].tr('^A-Za-z0-9_', '')}.json") )
    data['basePath'] = Setting.app_url
    # data['apis'].each { |api| api['path'] = 'api-docs/' + api['path'] }
    render :json => data
  end
end
