require "json"

class FileObject
  def to_json(*args)
    {
      id:,
      name:,
      path:,
      extension:,
      file_type:,
      metadata:,
      documents: documents.map(&:to_json)
    }.to_json(*args)
  end
end

class Document
  def to_json(*args)
    {
      id:,
      content:,
      main_topics:,
      tagged:,
      speech_acts:,
      transitivity:,
      llm_analysis:,
      paragraphs: paragraphs.map(&:to_json)
    }.to_json(*args)
  end
end

class Paragraph
  def to_json(*args)
    {
      id:,
      text:,
      sentences: sentences.map(&:to_json),
      topic: topic&.to_json
    }.to_json(*args)
  end
end

class Sentence
  def to_json(*args)
    {
      id:,
      text:,
      phrases: phrases.map(&:to_json),
      words: words.map(&:to_json),
      topic: topic&.to_json
    }.to_json(*args)
  end
end

class Phrase
  def to_json(*args)
    {
      id:,
      text:,
      words: words.map(&:to_json)
    }.to_json(*args)
  end
end

class Word
  def to_json(*args)
    {
      id:,
      text:,
      pos:,
      tag:,
      dep:,
      ner:
    }.to_json(*args)
  end
end

class Topic
  def to_json(*args)
    {
      id:,
      name:
    }.to_json(*args)
  end
end
