class CreateFileHandlers < ActiveRecord::Migration[7.0]
  def change
    create_table :file_handlers, &:timestamps
  end
end
