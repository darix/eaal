#--
# EAAL by Peter Petermann <PeterPetermann@gmx.net>
# This library is licensed under the terms found in
# the LICENSE file distributed with it
#++
module EAAL

    module Rowset

        class RowsetBase < Array
            attr_accessor :name, :columns, :rowclass
            
            def create_row(xml)
                row = self.rowclass.new
                self.columns.each { |colname|
                    row.send(colname +"=", xml[colname]) # row content ignored so far (needs to be added!!!)
                }
                if xml.containers.length > 0
                    xml.containers.each { |child|
                        el = EAAL::Result::ResultElement.parse_element(self.rowclass.name, child)
                        row.add_element(el.name, el)
                    }
                end
               row
            end
        end
        
        class RowBase < EAAL::Result::ResultContainer
        end
        
        def self.new(prefix, xml)
            name = xml['name']
            columns = xml['columns'].split(',')
            
            classname = prefix + 'Rowset' + name.capitalize
            rowname = classname + 'Row'
            
            if not Object.const_defined? classname
                klass = Object.const_set(classname, Class.new(EAAL::Rowset::RowsetBase))    
            else
                klass = Object.const_get(classname)
            end
            rowset = klass.new
            
            if not Object.const_defined? rowname
                klass = Object.const_set(rowname, Class.new(EAAL::Rowset::RowBase))
                klass.class_eval do
                    attr_accessor *columns
                end
            else
                klass = Object.const_get(rowname)
            end
            
            rowset.name = name
            rowset.columns = columns
            rowset.rowclass = klass
            xml.containers.each{ |row|
                rowset << rowset.create_row(row)
            }
            rowset
        end
    end
end