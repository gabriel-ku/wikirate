# -*- encoding : utf-8 -*-
require 'timecop'

require_dependency 'card'

class SharedData

  def self.account_args hash
    { "+*account" => { "+*password" =>'joe_pass' }.merge( hash ) }
  end

  def self.add_wikirate_data

    Card::Cache.reset_global
    Card::Env.reset
    Card::Auth.as_bot
    
    Card.create! :name=>'Death Star', :type=>'company', :subcards=> {
      '+about'  => { :content=>"Judge me by my size, do you?" }
    }
    Card.create! :name=>'Force', :type=>'topic', :subcards=> {
      '+about'  => { :content=>"A Jedi uses the Force for knowledge and defense, never for attack." }
    }
    Card.create! :name=>'Death Star+Force', :type=>'analysis', :subcards=> {
      '+article'  => { :content=>"I'm your father!" }
    }
    
    sourcepage = Card.create! :type_id=>Card::SourceID, :subcards=>{ 
      '+Link' => {:content=> 'http://www.wikiwand.com/en/Star_Wars'},
      '+company' => { :content=>"[[Death Star]]",         :type_id=>Card::PointerID },
      '+topic'   => { :content=>"[[Force]]",              :type_id=>Card::PointerID }
    }
    Card.create! :name=>'Death Star uses dark side of the Force', :type_id=>Card::ClaimID, :subcards=> {
      '+source'  => { :content=>"[[#{sourcepage.name}]]", :type_id=>Card::PointerID }, 
      '+company' => { :content=>"[[Death Star]]",         :type_id=>Card::PointerID },
      '+topic'   => { :content=>"[[Force]]",              :type_id=>Card::PointerID }
    }
    Card.create! :name=>'Jedi+disturbances in the Force', :type_id=>Card::MetricID
    Card.create! :name=>'Jedi+deadliness', :type_id=>Card::MetricID
    Card.create! :name=>'Jedi+disturbances in the Force+Death Star', :content=>'yes'
    Card.create! :name=>'Jedi+deadliness+Death Star', :content=>'high'
  end
end
