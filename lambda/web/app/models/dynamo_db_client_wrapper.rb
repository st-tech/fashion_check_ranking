require 'aws-sdk-dynamodb'

class DynamoDBClientWrapper
  def dynamo_db
    @dynamo_db ||= Aws::DynamoDB::Client.new
  end

  def create_table(table_schema)
    result = dynamo_db.create_table table_schema
    result.to_h
  end

  def scan(params)
    dynamo_db.scan(params).items
  end

  def put_item(params)
    dynamo_db.put_item(params)
  end
end
