Rails.application.config.after_initialize do

    SearchResultData.class_eval do
        def self.ACCESSION_FACETS
            ["collection_management_processing_status_u_ustr", "baseline_u_sbool", "collection_management_processing_priority_u_ustr", "classification_identifiers_u_sstr", "accession_date_year", "sources_u_sstr"]
        end
    end

end