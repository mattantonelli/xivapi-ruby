# Collection of requests that can be made to XIVAPI
module XIVAPI::Request
  include XIVAPI::HTTP

  # The results limit applied to Lodestone requests
  LODESTONE_LIMIT = 50.freeze

  # Options used to retrieve all data when querying a character
  ALL_CHARACTER_DATA = 'AC,FR,FC,FCM,PVP'.freeze

  # @param indexes [String, Array <String>] One or more indexes to search on
  # @param string [String] Value to search for in the string column
  # @param string_column [String] Column to perform the string search on
  # @param string_algo [String] Algorithm to use for the search
  # @param sort_field [String] Column to sort results by
  # @param sort_order [String] Order to sort results by
  # @param limit [Integer] Total number of results to limit to
  # @param body [Hash] Request body for advanced ElasticSearch queries
  # @param filters [String, Array <String>] One or more filters to search on
  # @param columns [String, Array <String>] One or more columns to limit results to
  # @return [XIVAPI::Paginator] Enumerable search results
  def search(indexes: [], string: '', string_column: nil, string_algo: nil,
             sort_field: nil, sort_order: nil, limit: 100, body: nil, filters: [], columns: [])
    params = { indexes: [*indexes].join(','), string: string, string_column: string_column, string_algo: string_algo,
               sort_field: sort_field, sort_order: sort_order, filters: [*filters].join(','), columns: [*columns].join(',') }
    XIVAPI::Paginator.new(self, params, 'search', limit, body)
  end

  # @param string [String] String of lore to search for
  # @param limit [Integer] Total number of results to limit to
  # @return [XIVAPI::Paginator] Enumerable lore results
  def lore(string: '', limit: 100)
    XIVAPI::Paginator.new(self, { string: string }, 'lore', limit)
  end

  # @param name [String] Name of the content (e.g. Achievement, Action, Item)
  # @param ids [Integer, Array<Integer>] One or more IDs to retrieve
  # @param minify [true, false] Minify resulting data where depth > 1
  # @param limit [Integer] Total number of results to limit to
  # @param columns [String, Array <String>] One or more columns to limit results to
  # @return [Array<String>, OpenStruct, XIVAPI::Paginator]
  #   Calling with no parameters will return the list of content names
  #   Calling with a name and a single ID will return that specific content
  #   Calling with a name and not a singe ID will return enumerable results
  def content(name: nil, ids: [], minify: false, limit: 100, columns: [])
    if name.nil?
      request(self, 'content')
    elsif [*ids].size == 1
      params = { minify: minify ? 1 : 0, columns: [*columns].join(',') }
      request(self, "#{name}/#{[*ids].first}", params)
    else
      params = { ids: [*ids].join(','), columns: [*columns].join(',') }
      XIVAPI::Paginator.new(self, params, name, limit)
    end
  end

  # @param group [true, false] Group the servers by data center
  # @return [Array<String>] List of servers
  def servers(group: false)
    endpoint = group ? 'servers/dc' : 'servers'
    request(self, endpoint)
  end

  # @param id [Integer] Character ID
  # @param all_data [true, false] Return the full set of character data
  # @param data [String, Array <String>] Additional data to request, see: https://xivapi.com/docs/Character#character
  # @param columns [String, Array <String>] One or more columns to limit results to
  # @return [OpenStruct] The requested character
  def character(id: nil, all_data: false, data: [], columns: [])
    params = { data: character_data(all_data, data), columns: [*columns].join(',') }
    request(self, "character/#{id}", params)
  end

  # @param name [String] Character name
  # @param server [String] Character server
  # @param columns [String, Array <String>] One or more columns to limit results to
  # @return [XIVAPI::Paginator] Enumerable search results
  def character_search(name: nil, server: nil, columns: [])
    params = { name: name, server: server, columns: [*columns].join(',') }
    XIVAPI::Paginator.new(self, params, 'character/search', LODESTONE_LIMIT)
  end

  # @param id [Integer] Character ID
  # @param token [String] Verification token to check for
  # @return [true, false] Whether or not the character is verified
  def character_verified?(id: nil, token: nil)
    character(id: id, columns: 'Character.Bio').character.bio.match?(token)
  end

  # @param id [Integer] Free company ID
  # @param members [true, false] Return member data
  # @param columns [String, Array <String>] One or more columns to limit results to
  # @return [OpenStruct] The requested free company
  def free_company(id: nil, members: false, columns: [])
    params = { data: members ? 'FCM' : nil, columns: [*columns].join(',') }
    request(self, "freecompany/#{id}", params)
  end

  # @param name [String] Free company name
  # @param server [String] Free company server
  # @param columns [String, Array <String>] One or more columns to limit results to
  # @return [XIVAPI::Paginator] Enumerable search results
  def free_company_search(name: nil, server: nil, columns: [])
    params = { name: name, server: server, columns: [*columns].join(',') }
    XIVAPI::Paginator.new(self, params, 'freecompany/search', LODESTONE_LIMIT)
  end

  # @param id [Integer] Linkshell ID
  # @param columns [String, Array <String>] One or more columns to limit results to
  # @return [OpenStruct] The requested linkshell
  def linkshell(id: nil, columns: [])
    params = { columns: [*columns].join(',') }
    request(self, "linkshell/#{id}", params)
  end

  # @param name [String] Linkshell name
  # @param server [String] Linkshell server
  # @param columns [String, Array <String>] One or more columns to limit results to
  # @return [XIVAPI::Paginator] Enumerable search results
  def linkshell_search(name: nil, server: nil, columns: [])
    params = { name: name, server: server, columns: [*columns].join(',') }
    XIVAPI::Paginator.new(self, params, 'linkshell/search', LODESTONE_LIMIT)
  end

  # @param id [Integer] PVP team ID
  # @param columns [String, Array <String>] One or more columns to limit results to
  # @return [OpenStruct] The requested PVP team
  def pvp_team(id: nil, columns: [])
    params = { columns: [*columns].join(',') }
    request(self, "pvpteam/#{id}", params)
  end

  # @param name [String] PVP team name
  # @param server [String] PVP team server
  # @param columns [String, Array <String>] One or more columns to limit results to
  # @return [XIVAPI::Paginator] Enumerable search results
  def pvp_team_search(name: nil, server: nil, columns: [])
    params = { name: name, server: server, columns: [*columns].join(',') }
    XIVAPI::Paginator.new(self, params, 'pvpteam/search', LODESTONE_LIMIT)
  end

  # @return [Array<OpenStruct>] List of game patches
  def patch_list
    request(self, 'patchlist')
  end

  private
  def character_data(all_data, data)
    all_data ? ALL_CHARACTER_DATA : [*data].join(',')
  end
end
