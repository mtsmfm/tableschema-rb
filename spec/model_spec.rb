require 'spec_helper'

describe JsonTableSchema::Model do

  let(:schema) {
    {
      "fields" => [
          {
              "name" => "id",
              "type" => "string",
              "constraints" => {
                  "required" => true,
              }
          },
          {
              "name" => "height",
              "type" => "number",
              "constraints" => {
                  "required" => false,
              }
          },
          {
              "name" => "age",
              "type" => "integer",
              "constraints" => {
                  "required" => false,
              }
          },
          {
              "name" => "name",
              "type" => "string",
              "constraints" => {
                  "required" => true,
              }
          },
          {
              "name" => "occupation",
              "type" => "string",
              "constraints" => {
                  "required" => false,
              }
          },

      ]
    }
  }

  let(:schema_min) {
    {
      "fields" => [
          {
              "name" => "id"
          },
          {
              "name" => "height"
          }
      ]
    }
  }

  it "returns headers" do
    s = JsonTableSchema::Schema.new(schema)
    expect(s.headers.count).to eq(5)
  end

  it "returns required headers" do
    s = JsonTableSchema::Schema.new(schema)
    expect(s.required_headers.count).to eq(2)
  end

  context "check for field presence" do

    it "returns true" do
      s = JsonTableSchema::Schema.new(schema)
      expect(s.has_field?('name')).to be true
    end

    it "returns false" do
      s = JsonTableSchema::Schema.new(schema)
      expect(s.has_field?('religion')).to be false
    end

  end

  it "gets fields by type" do
    s = JsonTableSchema::Schema.new(schema)

    expect(s.get_fields_by_type('string').count).to eq(3)
    expect(s.get_fields_by_type('number').count).to eq(1)
    expect(s.get_fields_by_type('integer').count).to eq(1)
  end

  context 'get type' do

    it 'gets the type of a field' do
      s = JsonTableSchema::Schema.new(schema)
      expect(s.get_type('id')).to eq('string')
    end

    it 'gets a default type' do
      s = JsonTableSchema::Schema.new(schema_min)
      expect(s.get_type('id')).to eq('string')
    end

  end

  context 'get constraints' do

    it 'gets the constraints for a field' do
      s = JsonTableSchema::Schema.new(schema)
      expect(s.get_constraints('id')).to eq({"required" => true})
    end

    it 'returns an empty hash where there are no constraints' do
      s = JsonTableSchema::Schema.new(schema_min)
      expect(s.get_constraints('id')).to eq({})
    end

  end

  context 'case insensitive headers' do

    let(:new_schema) {
      new_schema = schema.dup
      new_schema['fields'].map { |f| f['name'].capitalize! }
      new_schema
    }

    it 'with headers' do
      s = JsonTableSchema::Schema.new(new_schema, case_insensitive_headers: true)
      expect(s.headers).to eq(['id', 'height', 'age', 'name', 'occupation'])
    end

    it 'with required' do
      s = JsonTableSchema::Schema.new(new_schema, case_insensitive_headers: true)
      expect(s.required_headers).to eq(['id', 'name'])
    end

  end

  it 'sets defaults' do
    s = JsonTableSchema::Schema.new(schema_min)
    expect(s.get_fields_by_type('string').count).to eq(2)
  end

  it 'does not set fields as required by default' do
     hash = {
       "fields" => [
        {"name" => "id", "constraints" => {"required" => true}},
        {"name" => "label"}
       ]
     }

     s = JsonTableSchema::Schema.new(hash)
     expect(s.required_headers.count).to eq(1)
  end

  context 'primary key' do

    it 'returns a single primary key as an array' do
      schema = load_schema('schema_valid_pk_string.json')
      s = JsonTableSchema::Schema.new(schema)
      expect(s.primary_keys).to eq(['id'])
    end

    it 'returns the primary key as an array' do
      schema = load_schema('schema_valid_pk_array.json')
      s = JsonTableSchema::Schema.new(schema)
      expect(s.primary_keys).to eq(['id', 'title'])
    end

    it 'returns an empty array if there is no primary key' do
      s = JsonTableSchema::Schema.new(schema_min)
      expect(s.primary_keys).to eq([])
    end

  end

  context 'foreign key' do

    it 'with a valid foreign key string' do
      schema = load_schema('schema_valid_fk_string.json')
      schema = JsonTableSchema::Schema.new(schema)
      expect(schema.foreign_keys).to eq([
        {
            "fields" => "state",
            "reference" => {
                "datapackage" => "http://data.okfn.org/data/mydatapackage/",
                "resource" => "the-resource",
                "fields" => "state_id"
            }
        }
      ])
    end

    it 'with a valid foreign key self reference' do
      schema = load_schema('schema_valid_fk_string_self_referencing.json')
      schema = JsonTableSchema::Schema.new(schema)
      expect(schema.foreign_keys).to eq([
        {
            "fields" => "parent",
            "reference" => {
                "datapackage" => "",
                "resource" => "self",
                "fields" => "id"
            }
        }
      ])
    end

    it 'with a valid foreign key array' do
      schema = load_schema('schema_valid_fk_array.json')
      schema = JsonTableSchema::Schema.new(schema)
      expect(schema.foreign_keys).to eq([
          {
              "fields" => ["id", "title"],
              "reference" => {
                  "datapackage" => "http://data.okfn.org/data/mydatapackage/",
                  "resource" => "the-resource",
                  "fields" => ["fk_id", "title_id"]
              }
          }
      ])
    end

    it 'returns an empty array if there is no foreign key' do
      s = JsonTableSchema::Schema.new(schema_min)
      expect(s.foreign_keys).to eq([])
    end

  end

end

#
# def test_fields_arent_required_by_default(self):
#     schema = {
#         "fields": [
#             {"name": "id", "constraints": {"required": True}},
#             {"name": "label"}
#         ]
#     }
#     m = model.SchemaModel(schema)
#     self.assertEqual(len(m.required_headers), 1)
#
# def test_schema_is_not_mutating(self):
#     schema = {"fields": [{"name": "id"}]}
#     schema_copy = copy.deepcopy(schema)
#     model.SchemaModel(schema)
#     self.assertEqual(schema, schema_copy)
#
#
# class TestData(base.BaseTestCase):
# def setUp(self):
#     self.schema = {
#         "fields": [
#             {
#                 "name": "id",
#                 "type": "string",
#                 "constraints": {
#                     "required": True,
#                 }
#             },
#             {
#                 "name": "height",
#                 "type": "number",
#                 "constraints": {
#                     "required": False,
#                 }
#             },
#             {
#                 "name": "age",
#                 "type": "integer",
#                 "constraints": {
#                     "required": False,
#                 }
#             },
#             {
#                 "name": "name",
#                 "type": "string",
#                 "constraints": {
#                     "required": True,
#                 }
#             },
#             {
#                 "name": "occupation",
#                 "type": "string",
#                 "constraints": {
#                     "required": False,
#                 }
#             },
#
#         ]
#     }
#     super(TestData, self).setUp()
#
# def test_convert_row(self):
#     m = model.SchemaModel(self.schema)
#     converted_row = list(m.convert_row(
#         'string', '10.0', '1', 'string', 'string'))
#     self.assertEqual(['string', Decimal(10.0), 1, 'string', 'string'],
#                      converted_row)
#
# def test_convert_row_null_values(self):
#     m = model.SchemaModel(self.schema)
#     converted_row = list(m.convert_row('string', '', '-', 'string', 'null'))
#     assert ['string', None, None, 'string', None] == converted_row
#
# def test_convert_row_too_few_items(self):
#     m = model.SchemaModel(self.schema)
#     self.assertRaises(exceptions.ConversionError, list,
#                       m.convert_row('string', '10.0', '1', 'string'))
#
# def test_convert_row_too_many_items(self):
#     m = model.SchemaModel(self.schema)
#     self.assertRaises(exceptions.ConversionError, list,
#                       m.convert_row('string', '10.0', '1', 'string',
#                                     'string', 'string', 'string',
#                                     fail_fast=True))
#
# def test_convert_row_wrong_type_fail_fast(self):
#     m = model.SchemaModel(self.schema)
#     self.assertRaises(exceptions.InvalidCastError, list,
#                       m.convert_row('string', 'notdecimal', '10.6',
#                                     'string', 'string', fail_fast=True))
#
# def test_convert_row_wrong_type_multiple_errors(self):
#     m = model.SchemaModel(self.schema)
#     with self.assertRaises(exceptions.MultipleInvalid) as cm:
#         list(m.convert_row('string', 'notdecimal', '10.6', 'string',
#                            'string'))
#         self.assertEquals(2, len(cm.exception.errors))
#
# def test_convert_rows(self):
#     m = model.SchemaModel(self.schema)
#     rows = m.convert([['string', '10.0', '1', 'string', 'string'],
#                       ['string', '10.0', '1', 'string', 'string'],
#                       ['string', '10.0', '1', 'string', 'string'],
#                       ['string', '10.0', '1', 'string', 'string'],
#                       ['string', '10.0', '1', 'string', 'string']])
#     for row in rows:
#         self.assertEqual(['string', Decimal(10.0), 1, 'string', 'string'],
#                          row)
#
# def test_convert_rows_invalid_in_various_rows_fail_fast(self):
#     m = model.SchemaModel(self.schema)
#     self.assertRaises(
#         exceptions.InvalidCastError,
#         list,
#         m.convert(
#             [['string', 'not', '1', 'string', 'string'],
#              ['string', '10.0', '1', 'string', 'string'],
#              ['string', 'an', '1', 'string', 'string'],
#              ['string', '10.0', '1', 'string', 'string'],
#              ['string', '10.0', 'integer', 'string', 'string']],
#             fail_fast=True)
#     )
#
# def test_convert_rows_invalid_in_various_rows(self):
#     m = model.SchemaModel(self.schema)
#     with self.assertRaises(exceptions.MultipleInvalid) as cm:
#         list(m.convert([['string', 'not', '1', 'string', 'string'],
#                         ['string', '10.0', '1', 'string', 'string'],
#                         ['string', 'an', '1', 'string', 'string'],
#                         ['string', '10.0', '1', 'string', 'string'],
#                         ['string', '10.0', 'integer', 'string', 'string']])
#              )
#         self.assertEquals(3, len(cm.errors))
#
# def test_convert_rows_invalid_varying_length_rows(self):
#     m = model.SchemaModel(self.schema)
#     with self.assertRaises(exceptions.MultipleInvalid) as cm:
#         list(m.convert([['string', '10.0', '1', 'string'],
#                         ['string', '10.0', '1', 'string', 'string'],
#                         ['string', '10.0', '1', 'string', 'string', 1],
#                         ['string', '10.0', '1', 'string', 'string'],
#                         ['string', '10.0', '1', 'string', 'string']])
#              )
#         self.assertEquals(2, len(cm.errors))
#
# def test_convert_rows_invalid_varying_length_rows_fail_fast(self):
#     m = model.SchemaModel(self.schema)
#     self.assertRaises(
#         exceptions.ConversionError,
#         list,
#         m.convert([['string', '10.0', '1', 'string'],
#                    ['string', '10.0', '1', 'string', 'string'],
#                    ['string', '10.0', '1', 'string', 'string', 1],
#                    ['string', '10.0', '1', 'string', 'string'],
#                    ['string', '10.0', '1', 'string', 'string']],
#                   fail_fast=True)
#     )






# def test_invalid_jts_raises(self):
#     source = os.path.join(self.data_dir, 'schema_invalid_empty.json')
#
#     self.assertRaises(exceptions.InvalidSchemaError,
#                       model.SchemaModel, source)