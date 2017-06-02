class CommonIndexer
  add_indexer_initialize_hook do |indexer|
    indexer.add_document_prepare_hook {|doc, record|
      if doc['primary_type'] == 'accession'
        sources = record['record']['linked_agents'].select{|link| link['role'] === 'source'}
        doc['sources_u_sstr'] = sources.collect{|link| link['_resolved']['display_name']['sort_name']} if not sources.empty?

        if record['record']['collection_management']
          doc['collection_management_processing_priority_u_ustr'] = record['record']['collection_management']['processing_priority']
          doc['collection_management_processing_status_u_ustr'] = record['record']['collection_management']['processing_status']
        end

        if record['record']['classifications']
          doc['classification_identifiers_u_sstr'] = record['record']['classifications'].map { |c| ASUtils.to_json(c['_resolved']['path_from_root']['identifier']) }
        end
      end
    }
  end
end