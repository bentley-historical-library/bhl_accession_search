class CommonIndexer

  self.add_indexer_initialize_hook do |indexer|
    indexer.add_document_prepare_hook {|doc, record|
      if doc['primary_type'] == 'accession'
        sources = record['record']['linked_agents'].select{|link| link['role'] === 'source'}
        doc['sources_u_sstr'] = sources.collect{|link| link['_resolved']['display_name']['sort_name']} if not sources.empty?

        if record['record']['collection_management']
          doc['collection_management_processing_priority_u_ustr'] = record['record']['collection_management']['processing_priority']
          doc['collection_management_processing_status_u_ustr'] = record['record']['collection_management']['processing_status']
        end

        classification_identifiers = []
        if doc['enum_1_enum_s']
          classification_identifiers.concat(doc['enum_1_enum_s'])
        end
        if doc['enum_2_enum_s']
          classification_identifiers.concat(doc['enum_2_enum_s'])
        end
        if doc['enum_3_enum_s']
          classification_identifiers.concat(doc['enum_3_enum_s'])
        end
        doc['classification_identifiers_u_sstr'] = classification_identifiers
        doc['baseline_u_sbool'] = record['record']['user_defined']['boolean_2']
      end
    }
  end
  
end