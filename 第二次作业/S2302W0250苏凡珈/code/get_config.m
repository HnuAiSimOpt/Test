function config = get_config(defaultConfig,userConfig)
    
    

    config = defaultConfigp;
    
    
 
    defaultFields = fieldnames(defaultConfig);
    
    

    userFields = fieldnames(userConfig);
    nUserFields = length(userFields);
    
    

    for i = 1:nUserFields
        userField = userFields{i};
        isField = strcmpi(defaultFields,userField);
        if nnz(isField) == 1
            thisField = defaultFields{isField};
            config.(thisField) = userConfig.(userField);
        end
    end
    
end

