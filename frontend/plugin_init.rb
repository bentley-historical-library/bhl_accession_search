Rails.application.config.after_initialize do

    # Redefine the default SearchResultData.ACCESSION_FACETS array
    SearchResultData.class_eval do
        def self.ACCESSION_FACETS
            ["collection_management_processing_status_u_ustr", "baseline_u_sbool", "collection_management_processing_priority_u_ustr", "classification_identifiers_u_sstr", "accession_date_year", "sources_u_sstr"]
        end
    end

    ApplicationHelper.class_eval do
        alias_method :render_aspace_partial_pre_bhl_accession_search, :render_aspace_partial
        def render_aspace_partial(args)
            if args[:partial] == "search/listing"
                # Replace the default ArchivesSpace search listing for the accession listing
                if controller.controller_name == 'accessions' && controller.action_name == 'index'
                    args[:partial] = "accessions/search/listing"
                end
            end

            render_aspace_partial_pre_bhl_accession_search(args)
        end
    end
end