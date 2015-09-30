#!/usr/bin/env ruby

require 'octokit'
require 'dotenv'
Dotenv.load

TOKEN = ENV['ACCESS_TOKEN']
ORGNAME = ENV['ORGANIZATION']

# Enable auto-pagination
# https://github.com/octokit/octokit.rb#auto-pagination
Octokit.auto_paginate = true

# Authenticate using a token of an org owner
@client = Octokit::Client.new(:access_token => TOKEN)

# Hash of { team, member } to be created
teams = {
  'ElGreco'               => 'atrianta',
  'nagios-autoIDM'        => 'coyiotis',
  'dlimen'                => 'coyiotis',
  'PlegmaOpenBMS'         => 'nikil511',
  'simbug'                => 'dkremmydas',
  'DigitalSIgnatureCheckGR' => 'thodoris',
  'Woocommerce-Payment-Gateways-Greek-Banks' => 'bekatoros',
  'meteoclima-android'    => 'spyrosel',
  'Meteoclima-Seasonal-Forecast' => 'gvarlas',
  'enhydris'              => 'aptiko',
  'wp-file-search'        => 'antoniom',
  'adeies-form'           => 'Jimdem',
  'thermostatPI'          => 'karabill',
  'system-of-traffic-lights-and-raspberry-pi-for-air-quality-estimation' => 'katekats',
  'BusinessPi'            => 'cerebrux',
  'TRACEOIL'              => 'sotirisb',
  'mult_bus'              => 'naturangel',
  'FarmIT'                => 'imktks',
  'GSLT'                  => 'giannispappas',
  'DiavgeiaInsights'      => 'tolvog',
  'Sopho'                 => 'thedevelopersgreece',
  'beescale'              => 'stathisliou',
  'unity-social-network'  => 'meletakis',
  'csa-wp-plugin'         => 'haridimos',
  'ICSee-v1'              => 'AlexJoom',
  'ICStudy-v1'            => 'AlexJoom',
  'OpenMRS-translation'   => 'dmagoul',
  'smartt-mobile'         => 'tsadimas',
  'HDL-HELP'              => 'tsiourisk',
  'REMED'                 => 'dgatsios',
  'mental-control'        => 'tsiourisk',
  'apospaseis'            => 'stougsch',
  'BioTaxonomy'           => 'faysvas',
  'studentsofeverything'  => 'Weareyond',
  'KiCad_EDA_Greece'      => 'mmisirlis',
  'countrer'              => 'georgepoulos',
  'CMake-Docker'          => 'progtologist',
  'WeatherPiStation'      => 'xaxiris',
  'droneLifeguard'        => 'BillyTziv',
  'fpaUAV'                => 'konstantinabi',
  'ServeyStat'            => 'Ebrachos',
  'SocialCVBuilder'       => 'Ebrachos',
  'FarmerCalculator'      => 'athanasiats',
  'plumi'                 => 'mgogoulos',
  'WeatherXM'             => 'nikil511',
  'Edu-PreSchool'         => 'vorfan',
  'gramel'                => 'pkt',
  'OSM-Street-Network-Corrections-Attica' => 'jdafermos',
  'OSM-Street-Network-Corrections-Greece' => 'jdafermos',
  'greekmnts3d'           => 'kokkytos',
  'OpenDeskLab'           => 'progtologist',
  'pagkaki-project'       => 'chara88',
  'Jarrive'               => 'DimitrisKolovos',
  'donation-box'          => 'dkoukoul',
  'photometer'            => 'agelosfloros',
  'krini'                 => 'fotini-savvas',
  'cityZEN'               => 'piolecal',
  'GReceptionist'         => 'tsiourisk',
  'NursesShift'           => 'tolvog',
  'Kadoi-mpasketes'       => 'pandoheas',
  'filotis'               => 'aptiko',
  'E-CULTURE'             => 'limetechnology',
  'slic3r-el'             => 'HubITgr',
  'Kadoi-aporrimatwn'     => 'geoanagnos4',
  'The_Wi-Fi_seat'        => 'olgavenetsianou',
  'Ena-pagkaki-mes-stin-poli' => 'Angelaki-Sioutis-2015',
  'diabetes'              => 'pmanousis'
   }

# Existing teams, returns an array of Sawyer::Resource objects
# It is something like a hash but again not...
github_teams = @client.organization_teams(ORGNAME)

# Return a Hash of existing teams with their id { team-name, id }
github_teams_ids = github_teams.inject({}) do |ary,elmt|
  ary[elmt[:name]] = elmt[:id]
  ary
end

# Get existing team names into an array excluding 'Owners'
github_teams_names = github_teams.collect do |team|
  team[:name] unless team[:name] == 'Owners'
end.compact

# Get a team's id
def get_team_id(name)
  @client.organization_teams(ORGNAME).select do |team|
    team[:name] == name
  end.first[:id]
end

puts "There are #{github_teams_names.count} teams.\n"

# Gather invalid usernames in an array
invalid_usernames = []

# Create teams and assign repositories
teams.keys.each do |team|
  if github_teams_names.include?(team)
    puts "#{team} is already created..."
  else
    begin
      # Create repository
      # http://octokit.github.io/octokit.rb/Octokit/Client/Repositories.html#create_repository-instance_method
      @client.create_repo(team, { :organization => ORGNAME })
      puts "Created repo: #{team}..."
    rescue Octokit::UnprocessableEntity
      puts "#{team} - skipping repo creation..."
    end
    begin
      # Create team and add repository to it
      # http://octokit.github.io/octokit.rb/Octokit/Client/Organizations.html#create_team-instance_method
      @client.create_team(ORGNAME, { :name => team, :repo_names => ["#{ORGNAME}/#{team}"], :permission => 'admin' })
      puts "Created team: #{team}..."
    rescue Octokit::UnprocessableEntity
      puts "#{team} - skipping team creation..."
    end
    begin
      # Add team membership. We cannot use the existing github_teams array since we create a new team
      # http://octokit.github.io/octokit.rb/Octokit/Client/Organizations.html#add_team_membership-instance_method
      @client.add_team_membership(get_team_id(team), teams[team])
      puts "Added #{teams[team]} to team members of #{team}..."
    rescue
      puts "#{team} - skipping team addition..."
      invalid_usernames << teams[team]
    end
  end
end

unless invalid_usernames.empty?
  puts "\nThe following usernames are not valid:"
  invalid_usernames.each do |name|
    puts "- " + name
  end
end

# Fix permissions
# Give admin access to each team. Members can read from, push to, and add other teams to its repositories.
#github_teams.each do |team|
#  unless team[:permission] == 'admin'
#    @client.update_team(team[:id], { :permission => 'admin' })
#    puts "Permission set to admin for team #{team[:name]}..."
#  else
#    puts "#{team[:name]} already has admin access..."
#  end
#end
