# -*- encoding: utf-8 -*-
module Checkr
  class Candidate < Checkr::Base

    def self.create(params={}, api_key=nil)
      if valid?(params)
        uri = "/subaccounts/#{params[:subaccount_id]}" unless params[:subaccount_id].nil?
        uri = "#{uri}/candidates"
        response = self.post(uri, :body => params, :basic_auth => Checkr.auth(api_key) )

        if params[:employers].present?
          params[:employers].each do |employer|
            res = self.post("https://api.checkrhq-staging.net/v1/candidates/#{response['id']}/employers", :body => employer, :basic_auth => Checkr.auth(api_key))
            handle_response(res)
          end
        end

        if params[:school].present?
          res = self.post("https://api.checkrhq-staging.net/v1/candidates/#{response['id']}/schools", :body => params[:school], :basic_auth => Checkr.auth(api_key))
          handle_response(res)
        end

        handle_response(response)
      end
    end

    def self.find(id, api_key=nil)
      response = self.get("/candidates/#{id}?include=reports", :basic_auth => Checkr.auth(api_key) )
      handle_response(response)
    end

    def self.update(id, params={}, api_key=nil)
      response = self.post(
        "/candidates/#{id}",
        :body => params,
        :basic_auth => Checkr.auth(api_key)
      )

      handle_response(response)
    end

    def self.construct(params)
      reports = params["reports"]
 	    candidate = self.new(params.except_key('reports'))
 	    candidate.reports = []
 	    unless reports.nil? || reports.empty?
 	      reports.each do |report_attributes|
 	        candidate.reports << Checkr::Report.new(report_attributes)
 	      end
 	    end

 	    return candidate
    end

    protected

    def self.valid?(params)
      return true #TODO implement validation
    end

  end
end
