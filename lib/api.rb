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

class API < Sinatra::Base
  configure do
    set :server, :puma
    set :port, 4567
    set :bind, "0.0.0.0"
    set :show_exceptions, false
    set :raise_errors, false
    set :logging, false
  end

  before do
    content_type :json
    @collection = params[:collection]
    @object_bucket = params[:object_bucket]
    @object = params[:object]
    @splat_vals = params[:splat]
    @query_input = params[:query]
  end

  get "/" do
    # List available collections
    # ... (Implement logic to retrieve collections) ...
    { collections: %w[collection1 collection2] }.to_json
  end

  get "/:collection" do
    # Provide a summary of object counts for a specific collection
    # ... (Implement logic to retrieve object counts) ...
    {
      documents: Document.all.count,
      segments: Segment.all.count,
      words: Word.all.count
    }.to_json
  end

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

  get "/:collection/document/:document_name/segments" do
    # List all segments for a specific document
    document = Document.find(name: @object).first
    if document
      { segments: document.retrieve_segment_texts }.to_json
    else
      { error: "Document not found" }.to_json
    end
  end

  get "/:collection/document/:document_name/segments/:segment_name" do
    # Retrieve details of a specific segment
    # ... (Implement logic to retrieve segment details) ...
  end

  get "/:collection/document/:document_name/segments/:segment_name/words" do
    # List all words for a specific segment
    # ... (Implement logic to retrieve words for a segment) ...
  end

  get "/:collection/document/:document_name/segments/:segment_name/words/:word_name" do
    # Retrieve details of a specific word
    # ... (Implement logic to retrieve word details) ...
  end

  # ... (Add routes for other object buckets and their attributes) ...

  private

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
