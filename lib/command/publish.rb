class Command::Publish < Command::Base
  def self.command_name
    "publish"
  end

  def call
    create_or_update_live_content_item!
    LiveContentItemVersion.create!(new_attributes)
    draft.destroy!
  end

private
  def create_or_update_live_content_item!
    if existing_live_content_item
      existing_live_content_item.update_attributes!(new_attributes)
    else
      LiveContentItem.create!(new_attributes)
    end
  end

  def new_attributes
     draft.attributes
       .except("id")
       .merge("version" => next_version)
       .tap { |attributes|
          attributes['details'].merge!(change_history_hash)
        }
  end

  def change_history_hash
    if change_history.any?
      { "change_history" => change_history }
    else
      {}
    end
  end

  def change_history
    if update_type == 'major'
      assert_change_note_provided!
      existing_change_history + [
        {
          "public_timestamp" => Time.zone.now.iso8601,
          "note" => event.payload.fetch('change_note')
        }
      ]
    else
      existing_change_history
    end
  end

  def assert_change_note_provided!
    unless event.payload['change_note']
      raise EventProcessor::ProcessingError.new(
        Response::MissingRequiredField.new('change_note', 'required for major update')
      )
    end
  end

  def existing_change_history
    if existing_live_content_item
      existing_live_content_item.details.fetch('change_history', [])
    else
      []
    end
  end

  def update_type
    event.payload.fetch('update_type', 'minor')
  end

  def content_id
    event.payload['content_id']
  end

  def draft
    @draft ||= DraftContentItem.find_by_content_id!(content_id)
  end

  def latest_content_item_version
    @latest_content_item_version ||= LiveContentItemVersion.latest_version(content_id)
  end

  def next_version
    latest_content_item_version ? latest_content_item_version + 1 : 1
  end

  def existing_live_content_item
    @existing ||= LiveContentItem.find_by_content_id(content_id)
  end


end
