#!/usr/bin/env ruby
# frozen_string_literal: true

require "sinatra"
require "json"
require "ohm"
require "pastel"
require "mimemagic"
require "pdf-reader"
require "httparty"

# ... (Ohm model definitions from OhmModels.rb) ...

# This class defines the API for the Flowbots application.
#
# It provides endpoints for accessing and manipulating data stored in the Ohm models.
class API < Sinatra::Base
  # Configures the Sinatra application.
  #
  # Sets the server, port, bind address, exception handling, and logging options.
  configure do
    set :server, :puma
    set :port, 4567
    set :bind, "0.0.0.0"
    set :show_exceptions, false
    set :raise_errors, false
    set :logging, false
  end

  # Sets the content type to JSON for all requests.
  #
  # Extracts parameters from the request URL and stores them in instance variables.
  before do
    content_type :json
    @collection = params[:collection]
    @object_bucket = params[:object_bucket]
    @object = params[:object]
    @splat_vals = params[:splat]
    @query_input = params[:query]
  end

  # Handles the root route (GET /).
  #
  # Lists available collections.
  #
  # @return [String] A JSON response containing a list of collections.
  get "/" do
    # List available collections
    # ... (Implement logic to retrieve collections) ...
    { collections: %w[collection1 collection2] }.to_json
  end

  # Handles a GET request for a specific collection (GET /:collection).
  #
  # Provides a summary of object counts for the specified collection.
  #
  # @param collection [String] The name of the collection.
  #
  # @return [String] A JSON response containing object counts for the collection.
  get "/:collection" do
    # Provide a summary of object counts for a specific collection
    # ... (Implement logic to retrieve object counts) ...
    {
      documents: Document.all.count,
      segments: Segment.all.count,
      words: Word.all.count
    }.to_json
  end

  # Handles a GET request for all documents in a collection (GET /:collection/document).
  #
  # Lists all documents for the specified collection.
  #
  # @param collection [String] The name of the collection.
  #
  # @return [String] A JSON response containing a list of documents.
  get "/:collection/document" do
    # List all documents for a collection
    documents = Document.all.map do |document|
      {
        name: document.name,
        created_at: document.created_at
      }
    end
    { documents: }.to_json
  end

  # Handles a GET request for a specific document in a collection (GET /:collection/document/:document_name).
  #
  # Retrieves details of the specified document.
  #
  # @param collection [String] The name of the collection.
  # @param document_name [String] The name of the document.
  #
  # @return [String] A JSON response containing details of the document.
  get "/:collection/document/:document_name" do
    # Retrieve details of a specific document
    document = Document.find(name: @object).first
    if document
      {
        name: document.name,
        content: document.content,
        created_at: document.created_at,
        segments: document.retrieve_segment_texts,
        words: document.retrieve_word_texts
      }.to_json
    else
      { error: "Document not found" }.to_json
    end
  end

  # Handles a GET request for all segments in a specific document (GET /:collection/document/:document_name/segments).
  #
  # Lists all segments for the specified document.
  #
  # @param collection [String] The name of the collection.
  # @param document_name [String] The name of the document.
  #
  # @return [String] A JSON response containing a list of segments.
  get "/:collection/document/:document_name/segments" do
    # List all segments for a specific document
    document = Document.find(name: @object).first
    if document
      { segments: document.retrieve_segment_texts }.to_json
    else
      { error: "Document not found" }.to_json
    end
  end

  # Handles a GET request for a specific segment in a document (GET /:collection/document/:document_name/segments/:segment_name).
  #
  # Retrieves details of the specified segment.
  #
  # @param collection [String] The name of the collection.
  # @param document_name [String] The name of the document.
  # @param segment_name [String] The name of the segment.
  #
  # @return [String] A JSON response containing details of the segment.
  get "/:collection/document/:document_name/segments/:segment_name" do
    # Retrieve details of a specific segment
    # ... (Implement logic to retrieve segment details) ...
  end

  # Handles a GET request for all words in a specific segment (GET /:collection/document/:document_name/segments/:segment_name/words).
  #
  # Lists all words for the specified segment.
  #
  # @param collection [String] The name of the collection.
  # @param document_name [String] The name of the document.
  # @param segment_name [String] The name of the segment.
  #
  # @return [String] A JSON response containing a list of words.
  get "/:collection/document/:document_name/segments/:segment_name/words" do
    # List all words for a specific segment
    # ... (Implement logic to retrieve words for a segment) ...
  end

  # Handles a GET request for a specific word in a segment (GET /:collection/document/:document_name/segments/:segment_name/words/:word_name).
  #
  # Retrieves details of the specified word.
  #
  # @param collection [String] The name of the collection.
  # @param document_name [String] The name of the document.
  # @param segment_name [String] The name of the segment.
  # @param word_name [String] The name of the word.
  #
  # @return [String] A JSON response containing details of the word.
  get "/:collection/document/:document_name/segments/:segment_name/words/:word_name" do
    # Retrieve details of a specific word
    # ... (Implement logic to retrieve word details) ...
  end

  # ... (Add routes for other object buckets and their attributes) ...

  private

  # Sorts splat values from the request URL and organizes them into a hash.
  #
  # @param splat_vals [Array] The splat values from the request URL.
  #
  # @return [Hash] A hash containing sorted splat values.
  def splat_sort(splat_vals)
    @output = {}
    @output[:object] = @object
    @output[:object_bucket] = @object_bucket
    @output[:collection] = @collection
    @output[:splat_vals] = splat_vals

    if @object_bucket == "document"
      @output[:segments] = splat_vals[splat_vals.index("segments") + 1..-1] if @splat_vals.include?("segments")
      @output[:words] = splat_vals[splat_vals.index("words") + 1..-1] if @splat_vals.include?("words")
    end

    @output
  end
end

# ... (Rest of the code for setting up the API and handling requests) ...
