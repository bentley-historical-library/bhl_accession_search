Rails.application.config.after_initialize do

    SearchResultData.class_eval do
        def self.ACCESSION_FACETS
            ["accession_date_year", "collection_management_processing_status_u_ustr", "collection_management_processing_priority_u_ustr", "classification_identifiers_u_sstr", "sources_u_sstr"]
        end
    end

end