# frozen_string_literal: true
require 'rails_helper'
require 'json'

RSpec.describe "recommendation to recommendation relationships", type: :request do

  describe "get one recommendation to recommendation relationship" do
    let(:recommendation_recommendation) { FactoryGirl.create(:recommendation_recommendation) }
    it 'returns the recommendation releationship requested' do

      get "/recommendation_recommendations/#{recommendation_recommendation.id}"

      expected_json = 
      { "data"=>
        { "id"=>recommendation_recommendation.id.to_s, 
          "type"=>"recommendation_recommendations", 
          "attributes"=>
          { "created_at"=>recommendation_recommendation.created_at.in_time_zone.iso8601, 
             "updated_at"=>recommendation_recommendation.updated_at.in_time_zone.iso8601, 
             "recommendation_id"=>recommendation_recommendation.recommendation_id, 
             "other_recommendation_id"=>recommendation_recommendation.other_recommendation_id
          }
        }
      }

      json = JSON.parse(response.body)
 
      expect(response.status).to eq(200)
      expect(json).to eq(expected_json)
    end
  end

  describe "get all the recommendation to recommendation relationships" do 
    let(:recommendation_1) { FactoryGirl.create(:recommendation)}
    let(:recommendation_2) { FactoryGirl.create(:recommendation)}
    let(:recommendation_3) { FactoryGirl.create(:recommendation)}
    let!(:recommendation_recommendation_1) { FactoryGirl.create(:recommendation_recommendation, recommendation_id: recommendation_1.id, other_recommendation_id: recommendation_2.id) }
    let!(:recommendation_recommendation_2) { FactoryGirl.create(:recommendation_recommendation, recommendation_id: recommendation_2.id, other_recommendation_id: recommendation_3.id) }
    let!(:recommendation_recommendation_3) { FactoryGirl.create(:recommendation_recommendation, recommendation_id: recommendation_1.id, other_recommendation_id: recommendation_3.id) }
      
    it "returns all the linkable recommendations" do

      get "/recommendation_recommendations"

      expected_json = 
        { "data"=>
          [
            { "id"=>recommendation_recommendation_1.id.to_s, 
              "type"=>"recommendation_recommendations", 
              "attributes"=>
              { "created_at"=>recommendation_recommendation_1.created_at.in_time_zone.iso8601, 
                "updated_at"=>recommendation_recommendation_1.updated_at.in_time_zone.iso8601, 
                "recommendation_id"=>recommendation_recommendation_1.recommendation_id, 
                "other_recommendation_id"=>recommendation_recommendation_1.other_recommendation_id
              }
            }, 
            { "id"=>recommendation_recommendation_2.id.to_s, 
              "type"=>"recommendation_recommendations", 
              "attributes"=>
              { "created_at"=>recommendation_recommendation_2.created_at.in_time_zone.iso8601, 
                "updated_at"=>recommendation_recommendation_2.updated_at.in_time_zone.iso8601, 
                "recommendation_id"=>recommendation_recommendation_2.recommendation_id, 
                "other_recommendation_id"=>recommendation_recommendation_2.other_recommendation_id
              }
            }, 
            { "id"=>recommendation_recommendation_3.id.to_s, 
              "type"=>"recommendation_recommendations", 
              "attributes"=>
              { "created_at"=>recommendation_recommendation_3.created_at.in_time_zone.iso8601, 
                "updated_at"=>recommendation_recommendation_3.updated_at.in_time_zone.iso8601, 
                "recommendation_id"=>recommendation_recommendation_3.recommendation_id, 
                "other_recommendation_id"=>recommendation_recommendation_3.other_recommendation_id
              }
            }
          ]
        }

      json = JSON.parse(response.body)
      
      expect(response.status).to eq(200)
      expect(json).to eq(expected_json)
    end
  end
end