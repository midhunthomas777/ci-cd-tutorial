/*    
Class Name    : ParseCSVUtilityController
Purpose       : Utility Class for Parsing the CSV Files
Author        : Arunraj Radhakrishnan
Test Class    : 
Change History: -
*/

global class ParseCSVUtilityController {

        // Return a 2D String array with headers on first row
    public static List<List<String>> parseCSV(String contents,Boolean skipHeader) {
        
        System.debug('## parseCSV called with contents = ' + contents);
        // Determine if it is split by newLine(\n) or return carriage(\r) or a \r\nn
        Boolean hasNewLine = false;
        Boolean hasCarrReturn = false;
        
        //First check for a \r\n char
        if(contents.contains('\r\n')) {
            System.debug('## Contains at least one \'\\r\\n\' character');
            hasNewLine = true;
            hasCarrReturn = false;
        }
        else {
            //If not then check for either a /r or /n
            if(contents.contains('\n')) {
                System.debug('## Contains at least one newline character');
                hasNewLine = true;
            }
            if(contents.contains('\r')) {
                System.debug('## Contains at least one carriage return character');
                hasCarrReturn = true;
            }
        }
        
        List<List<String>> allFields = new List<List<String>>();
        if(hasNewLine && hasCarrReturn) {
            addError('The file contains both newline and carriage returns');
        }
        else {
            
            String splitBy = '\n';
            if(hasCarrReturn) {
                splitBy = '\r';
            }
            
            // replace instances where a double quote begins a field containing a comma
            // in this case you get a double quote followed by a doubled double quote
            // do this for beginning and end of a field
            contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
            // now replace all remaining double quotes - we do this so that we can reconstruct
            // fields with commas inside assuming they begin and end with a double quote
            contents = contents.replaceAll('""','DBLQT');
            // we are not attempting to handle fields with a newline inside of them
            // so, split on newline to get the spreadsheet rows
            List<String> lines = new List<String>();
            try {
                lines = contents.split(splitBy);
            } catch (System.ListException e) {
                System.debug('## Limits exceeded?' + e.getMessage());
            }
            System.debug('## About to check ' + lines.size() + ' lines...');
            Integer num = 0;
            
            for(String line : lines) {
                System.debug('## Parsing line: ' + line);
                // Deal with lines where 
               // if (line.replaceAll(',','').trim().length() == 0) continue; 
                
                
                // TODO: Deal with lines where all fields empty. Currently splits into an empty array.
                
                List<String> fields = line.split(',', -1);  
                List<String> cleanFields = new List<String>();
                String compositeField;
                Boolean makeCompositeField = false;
                System.debug('## About to read ' + fields.size() + ' fields...');
                for(String field : fields) {
                    if (field.startsWith('"') && field.endsWith('"')) {
                        cleanFields.add(field.replaceAll('DBLQT','"'));
                    } else if (field.startsWith('"')) {
                        makeCompositeField = true;
                        compositeField = field;
                    } else if (field.trim().endsWith('"') ) {
                        System.debug('field2::'+field);
                        compositeField += ',' + field;
                        cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                        makeCompositeField = false;
                    } else if (makeCompositeField) {
                        compositeField +=  ',' + field;
                    } else {
                        cleanFields.add(field.replaceAll('DBLQT','"'));
                    }
                }
                
                // Remove double quotes (if present) from start and end of each field
                List<String> noQuoteFields = new List<String>();
                for(String field : cleanFields) {
                    if(field.startsWith('"') && field.endsWith('"')) {
                        field = field.substring(1, field.length() - 1);
                    }                    
                    noQuoteFields.add(field);
                }
                allFields.add(noQuoteFields);
            }
        }
        
        if(skipHeader) {
            // Remove any rows before header row so that header row is first row:
            Integer headerRow = -1;
            for(Integer i=0; (i < allFields.size() && headerRow == -1) ; i++) {
                // Determine if all fields in this row are non-blank:
                List<String> row = allFields.get(i);
                Boolean isHeaderRow = true;
                
                for(String field : row) {
                    if(field == '') { // field is blank
                        isHeaderRow = false;
                    }
                }
                
                if(isHeaderRow) {
                    headerRow = i;
                }
            }
            System.debug('## headerRow ' +headerRow);
            
            for(Integer i=0; i < headerRow; i++) {
                allFields.remove(0);
            }
        }
        System.debug('## About to return ' + allFields.size() + ' lines...');
                   
        return allFields;
    }  
    
    public static void addError(String error) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
    }  
}