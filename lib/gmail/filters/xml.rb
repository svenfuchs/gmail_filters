module Gmail
  module Filters
    module Xml
      module Helpers
        def indent(str, level)
          str.split("\n").map { |str| [' ' * level, str].join }.join("\n")
        end
      end

      class Doc < Struct.new(:filters)
        include Helpers

        XML = <<~xml
          <?xml version='1.0' encoding='utf-8' ?>
          <feed xmlns:apps='http://schemas.google.com/apps/2006' xmlns='http://www.w3.org/2005/Atom'>
            <title>Mail Filters</title>
            <id>tag:mail.google.com,2008:filters:</id>
            <updated>2017-03-12T18:29:46Z</updated>
            <author>
              <name>%{author}</name>
              <email>%{email}</email>
            </author>
          %{entries}
          </feed>
        xml

        def render
          XML % attrs
        end

        private

          def attrs
            {
              author: filters.author || 'unknown',
              email: filters.email || 'unknown',
              entries: indent(entries.join, 2)
            }
          end

          def entries
            filters = self.filters.map(&:filters).flatten
            filters.map { |filter| Filter.new(filter).render }
          end
      end

      class Filter < Struct.new(:filter)
        include Helpers

        ENTRY = <<~xml
          <entry>
            <category term="filter"></category>
            <title>Mail Filter</title>
            <content></content>
          %s
          </entry>
        xml

        PROPERTY = <<~xml
          <apps:property name="%s" value="%s"></apps:property>
        xml

        ATTRS = {
          has:       :hasTheWord,
          label:     :label,
          archive:   :shouldArchive,
          delete:    :shouldTrash,
          mark_read: :shouldMarkAsRead
        }

        def render
          attrs = filter.to_h
          ATTRS.each { |attr| attrs[attr] ||= attr == :label ? nil : false }
          ENTRY % indent(properties.join, 2)
        end

        def properties
          filter.to_h.map { |name, value| PROPERTY % [ATTRS[name], value] }
        end
      end
    end
  end
end
