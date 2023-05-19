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
                # Apply custom accession columns
                if controller.controller_name == 'accessions' && controller.action_name == 'index'
                    action_column = @columns.pop if @columns.last.class.include?('actions')

                    @columns = []

                    add_multiselect_column if can_delete_search_results?('accession')

                    add_column("ID",
                               { :sortable => false },
                               proc {|result|
                                   result["_parsed_json"] ||= JSON.parse(result["json"])
                                   result["_parsed_json"]["id_0"]
                               })

                    add_column("Date",
                               { :sortable => false },
                               proc {|result|
                                   result["_parsed_json"] ||= JSON.parse(result["json"])
                                   result["_parsed_json"]["accession_date"]
                               })

                    add_column("Extent",
                               { :sortable => false },
                               proc {|result|
                                   result["_parsed_json"] ||= JSON.parse(result["json"])
                                   extent_statements = []
                                   result["_parsed_json"]["extents"].each do |extent|
                                       extent_number = extent["number"]
                                       extent_type = I18n.t('enumerations.extent_extent_type.' + extent["extent_type"], :default => extent["extent_type"])
                                       extent_statements << "#{extent_number} #{extent_type}"
                                   end
                                   extent_statements.join(", ")
                               })


                    add_column("Description",
                               { :sortable => false },
                               proc {|result|
                                   result["_parsed_json"] ||= JSON.parse(result["json"])
                                   clean_mixed_content(result["_parsed_json"]["content_description"].to_s).html_safe
                               })


                    add_column("Processing Info",
                               { :sortable => false },
                               proc {|result|
                                   result["_parsed_json"] ||= JSON.parse(result["json"])
                                   collection_management = result["_parsed_json"]["collection_management"] ? result["_parsed_json"]["collection_management"] : nil
                                   if collection_management
                                       out = ""
                                       out += "<div>Status: #{I18n.t("enumerations.collection_management_processing_status.#{collection_management["processing_status"]}", default: collection_management["processing_status"])}</div>" if collection_management["processing_status"]
                                       out += "<div>Priority: #{I18n.t("enumerations.collection_management_processing_priority.#{collection_management["processing_priority"]}", default: collection_management["processing_priority"])}</div>" if collection_management["processing_priority"]
                                       out.html_safe
                                   end
                               })


                    add_column("Classification",
                               { :sortable => false },
                               proc {|result|
                                   ASUtils.wrap(result["classification_identifiers_u_sstr"]).join(", ")
                               })


                    add_column("Donor",
                               { :sortable => false },
                               proc {|result|
                                   result["_parsed_json"] ||= JSON.parse(result["json"])
                                   donor = result["_parsed_json"]["linked_agents"][0] ? result["_parsed_json"]["linked_agents"][0]["_resolved"] : nil
                                   if donor
                                       donor_name = donor["title"]
                                       donor_number = donor["donor_details"][0] ? donor["donor_details"][0]["donor_number"] : "No Donor Number"
                                       "#{donor_name} (#{donor_number})<br>#{link_to "[view all from donor]", build_search_params({"add_filter_term" => {"sources_u_sstr" => donor_name}.to_json}) }".html_safe
                                   end
                               })

                    @columns << action_column
                end
            end

            render_aspace_partial_pre_bhl_accession_search(args)
        end
    end
end