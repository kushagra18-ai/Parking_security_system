function whitelist = load_whitelist()
%LOAD_WHITELIST  Returns the authorized license plate database.
%
%  In a production system this would query a secure database.
%  Here we use a struct array as an in-memory lookup table.
%
%  Output:
%    whitelist - struct with fields:
%                  .plates  : cell array of authorized plate strings
%                  .owners  : cell array of corresponding owner names

    whitelist.plates = {'UP16AB1234', ...   % Owner's primary vehicle
                        'DL01CD5678', ...   % Family car
                        'HR26EF9012', ...   % Authorized visitor
                        'MH12GH3456'};      % Company vehicle

    whitelist.owners = {'Jessica Goel (Owner)', ...
                        'Aditi Gupta (Family)', ...
                        'Kushagra Rastogi (Friend)', ...
                        'JIIT Campus Vehicle'};

    fprintf('   -> Whitelist loaded: %d authorized plates.\n', ...
            numel(whitelist.plates));
end
