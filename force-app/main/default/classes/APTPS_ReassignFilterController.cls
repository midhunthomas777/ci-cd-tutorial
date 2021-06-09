public with sharing class APTPS_ReassignFilterController  {
    
    public static final String REASSIGNED_TO_ID = 'reassignedToId';
    public static final String REASSIGNED_TO_NAME = 'reassignedToName';
    
    public static final String PARAM_NAME_ID = 'id';
    public static final String PARAM_NAME_SEARCH_TEXT = 'searchText';
    public static final String PARAM_NAME_PAGESIZE_DEFAULT = 'pageSizeDefault';
    public static final String PARAM_NAME_REASSIGN_TO_ID = 'reassignToId';
    public static final String PARAM_NAME_REASSIGN_TO_TYPE = 'reassignToType';
        
    // approval request
    private Apttus_Approval__Approval_Request__c request = null;
    public User currentUser{get; private set;}
    
    // reassign to user id & name
    private String reassignedToId = null;
    private String reassignedToName = null;
    private String reassignedToType = null;
    
    // search input text
    public String searchText {get; set;}
    
    // paging query locator
    private ApexPages.StandardSetController userSet = null;
    
    // user wrapper list
    public List<UserWrapper> userList = null;
    
    // limit rows
    public Integer limitRows = 500;
    
    // page size
    public Integer pageSize = 20;
    
    // total pages
    private Integer totalPages = null;
    
    // assignee matrix level
    private Integer assigneeMatrixLevel = 0;
    private String assigneeMatrixLevelStr = null;
        
    /**
     * Class Constructor with approval request standard controller
     * @param stdController the approval request object standard controller
     */
    public APTPS_ReassignFilterController(ApexPages.StandardController stdController) {
        Map<String, String> reqParams = ApexPages.currentPage().getParameters();
        
        request = (Apttus_Approval__Approval_Request__c) stdController.getRecord();
        
        request = getRequest(request.Id);
        // reassign to info provided?
        String searchTextStr = reqParams.get(PARAM_NAME_SEARCH_TEXT);
        if (!nullOrEmpty(searchTextStr)) {
            searchText = String.escapeSingleQuotes(searchTextStr);
        }
        
        // default page size
        String pageSizeStr = reqParams.get(PARAM_NAME_PAGESIZE_DEFAULT);
        if (!nullOrEmpty(pageSizeStr)) {
            pageSize = Integer.valueOf(String.escapeSingleQuotes(pageSizeStr));
        }
        
        // get current assignee matrix level
        if ('User' == request.Apttus_Approval__Assigned_To_Type__c) {
                    
            Apttus_Approval__Approval_Matrix__c matrix = getMatrix(request.Apttus_Approval__Assigned_To_Id__c);
            if (matrix != null) {
                assigneeMatrixLevelStr = matrix.Apttus_Approval__Approval_Level__c;
                assigneeMatrixLevel = getLevelNumber(assigneeMatrixLevelStr);
                // if level-6, user can select any level - he/she knows what they're doing?
                if (assigneeMatrixLevel == 6) {
                    assigneeMatrixLevel = 0;    
                }   
            }
        }
    }
    
    /**
     * Get reassigned-to name
     */
    public String getReassignedToName() {
        return reassignedToName;
    }
    
    /**
     * Get reassigned-to id
     */
    public String getReassignedToId() {
        return reassignedToId;
    }
    
    /**
     * Set reassigned-to name
     */
    public void setReassignedToName(String reassignName) {
        reassignedToName = reassignName;
    }
    
    /**
     * Return to approval request or return url.
     */
    public PageReference doReturn() {
        
        // back to reassign page without any selection
        PageReference pageRef = Page.Apttus_Approval__ApprovalRequestReassign2;
        Map<String, String> reqParams = pageRef.getParameters();
        reqParams.put(PARAM_NAME_ID, request.Id);
        
        pageRef.setRedirect(true);
        
        return pageRef;
    }
    
    /**
     * Choose user selection
     * @param assignedToId user Id bound to request
     * @param assignedToName user name bound to request
     * @return to previous page
     */
    public PageReference doChooseUser() {
        reassignedToId = (String) System.currentPageReference().getParameters().get(REASSIGNED_TO_ID);
        reassignedToName = (String) System.currentPageReference().getParameters().get(REASSIGNED_TO_NAME);
        // return back
        PageReference pageRef = Page.Apttus_Approval__ApprovalRequestReassign2;
        Map<String, String> reqParams = pageRef.getParameters();
        reqParams.put(PARAM_NAME_ID, request.Id);
        reqParams.put(PARAM_NAME_REASSIGN_TO_ID, reassignedToId);
        reqParams.put(PARAM_NAME_REASSIGN_TO_TYPE, 'User');
        
        pageRef.setRedirect(true);
        return pageRef;
    }
     
    /**
     * Performs the search action using user entered search text
     */
    public void doSearch() {
        // clear list - gets initialize in getUserList method
        userList = null;
        
        if (assigneeMatrixLevelStr == null) {
            doSearchWithoutLevel();
        } else {
            doSearchWithLevel();
        }
    }
     
    /**
     * Performs the search action using user entered search text
     */
    private void doSearchWithoutLevel() {
        String sq = '\'';
        
        // package namespace
        String nsPrefix = 'Apttus_Approval__';
                           
        try {
                    
            // Custom Code added by SD to add Motorola Filters - 10/17
            String appendqryStr ='';
            String currentAssignedToId = request.Apttus_Approval__Assigned_To_Id__c;
            String currentUserType = request.Apttus_Approval__Assigned_To_Type__c;
            
            /* 
            // Commented out by SD - 12/19 
            
            if (currentUserType == 'User')
            {
            
            	currentUser = [Select u.Name, u.APTPS_Region__c, u.APTPS_Agreement_RecordType__c, u.APTPS_Permissible_Assignee_Label__c, u.APTPS_Authorized_Dollar_Value__c FROM User u WHERE Id = :currentAssignedToId];
            	//currentUser = [Select u.Name, u.APTPS_Region__c, APTPS_Agreement_RecordType__c, u.APTPS_Authorized_Dollar_Value__c FROM User u WHERE Id = :currentAssignedToId];
            
            
            	// Get Region & Append to query
            	String region = currentUser.APTPS_Region__c;
            
            	if ((region != null) && (region != ''))
            	{           
                	// Get number of values in picklist
                	//String strFind = ';';
                	//String strReplace = sq + ',' + sq;
                	//String newRegion = region.replaceAll(strFind, strReplace);
                	String newRegion = fixMultiSelect(region);
                	appendqryStr = ' AND (APTPS_Region__c includes (' + sq + newregion + sq + '))';
            	}
            
            	// Get Permissable Assignee Label & Append to query
            	String assigneeLabel = currentUser.APTPS_Permissible_Assignee_Label__c;
            	if ((assigneeLabel != null) && (assigneeLabel != ''))
            	{
                	appendqryStr = appendqryStr + ' AND (APTPS_Permissible_Assignee_Label__c = ' + sq + assigneeLabel + sq + ')';
            	}
            
            	// Get RecordType & Append to query
            	String recordType = currentUser.APTPS_Agreement_RecordType__c;
            	if ((recordType != null) && (recordType != ''))
            	{
                	String newrecordType = fixMultiSelect(recordType);
                	appendqryStr = appendqryStr + ' AND (APTPS_Agreement_RecordType__c includes (' + sq + newrecordType + sq + '))';
            	}
            
            	// Get Authorized Dollar Value & Append to query
            	String authorizedDollarValue = currentUser.APTPS_Authorized_Dollar_Value__c;
            	if ((authorizedDollarValue != null) && (authorizedDollarValue != ''))
            	{
                	//appendqryStr = ' AND (APTPS_Authorized_Dollar_Value__c = ' + authorizedDollarValue + ')';
                	if (authorizedDollarValue == '$0 - <=$500K')
                	{
                    	//appendqryStr = ' AND (APTPS_Authorized_Dollar_Value__c in '('>$25M - <=$100M','>$100M'))';
                	}
                	else if (authorizedDollarValue == '>$500K - <=$10M')
                	{
                    	//appendqryStr = ' AND (APTPS_Authorized_Dollar_Value__c in '('>$25M - <=$100M','>$100M'))';
                	}
                	else if (authorizedDollarValue == '>$10M - <=$25M')
                	{
                    	//appendqryStr = ' AND (APTPS_Authorized_Dollar_Value__c in '('>$25M - <=$100M','>$100M'))';
                	}
                	else if (authorizedDollarValue == '>$25M - <=$100M')
                	{
                    	//appendqryStr = ' AND (APTPS_Authorized_Dollar_Value__c in '('>$25M - <=$100M','>$100M'))';
                	}
                	else
                	{
                    	//appendqryStr = ' AND (APTPS_Authorized_Dollar_Value__c = '>$100M')';
                	}
                
            	}
            
            	// Get agreement value
            	//Decimal totalAgreementValue = request.Apttus_Approval__Assigned_To_Id__c;
            }
            
            */
            
            
            //String qryStr = 'SELECT Id, Name, LastName, FirstName, UserRoleId, UserRole.Name, IsActive, APTPS_Region__c, APTPS_Agreement_RecordType__c, APTPS_Permissible_Assignee_Label__c, APTPS_Authorized_Dollar_Value__c ';
            String qryStr = 'SELECT Id, Name, LastName, FirstName, UserRoleId, UserRole.Name, IsActive ';
            //qryStr += ', (select Id, ';
            //qryStr += nsPrefix + 'Approval_Level__c, ';
            //qryStr += nsPrefix + 'Description__c';
            //qryStr += ' from ' + nsPrefix + 'Approval_Matrices__r)';
            qryStr += ' FROM User  WHERE IsActive = true ';
            
            if (!nullOrEmpty(searchText)) {
                String searchTerm = (searchText != null ? searchText : '').trim();
                // append wildcards to the search term
                searchTerm = (!searchTerm.startsWith('%') ? '%' + searchTerm : searchTerm); // Updated by SD - 10/16
                searchTerm = (!searchTerm.endsWith('%') ? searchTerm + '%' : searchTerm);
                
                qryStr += 'AND ';
                qryStr += 'Name LIKE ' + sq + String.escapeSingleQuotes(searchTerm) + sq;
            }               
            
            /* Commented out due to Motorola decision not to implement this for 11/22
            // Append Motorola specific filter
            if ((appendqryStr != '') && (appendqryStr != null))
            {
                qryStr += appendqryStr;
            }
            */
               
            qryStr += ' ORDER BY Name';
            
            // limit rows
            qryStr += ' LIMIT ' + Math.min(limitRows, 1000);
            System.debug('query=' + qryStr);
                
            // execute the query
            userSet = new ApexPages.StandardSetController(Database.getQueryLocator(qryStr));
            // set the page size
            userSet.setPageSize(pageSize);
                
        } catch (Exception ex) {
            // add error messages
            ApexPages.addMessages(ex);
            System.Debug(LoggingLevel.ERROR, ex.getMessage());
        }
    }
     
    /**
     * Performs the search action using user entered search text
     */
    private void doSearchWithLevel() {
        String sq = '\'';
        
        // package namespace
        /*String nsPrefix = (RuntimeContext.isDeployedInPackage() 
                           ? SystemUtil.PACKAGE_NAMESPACE + '__'
                           : '');*/
        String nsPrefix = 'Apttus_Approval__';
        
        try {
                    
                               
            String levelWhereClause = 'select ' + nsPrefix + 'User__c from ';
            levelWhereClause += nsPrefix + 'Approval_Matrix__c where ';
            levelWhereClause += nsPrefix + 'Is_Active__c = true and ';
            levelWhereClause += nsPrefix + 'Is_Valid__c = true and ';
            levelWhereClause += nsPrefix + 'Approval_Level__c >= ' + sq + assigneeMatrixLevelStr + sq;
        
            String qryStr = 'SELECT Id, Name, LastName, FirstName, UserRoleId, UserRole.Name, IsActive ';
            qryStr += ', (select Id, ';
            qryStr += nsPrefix + 'Approval_Level__c, ';
            qryStr += nsPrefix + 'Description__c';
            qryStr += ' from ' + nsPrefix + 'Approval_Matrices__r)';
            qryStr += ' FROM User WHERE IsActive = true AND Id IN (' + levelWhereClause + ')';
            
            if (!nullOrEmpty(searchText)) {
                String searchTerm = (searchText != null ? searchText : '').trim();
                // append wildcards to the search term
                searchTerm = (!searchTerm.startsWith('%') ? '%' + searchTerm : searchTerm); // Updated by SD - 10/16
                searchTerm = (!searchTerm.endsWith('%') ? searchTerm + '%' : searchTerm);
                
                qryStr += 'AND ';
                qryStr += 'Name LIKE ' + sq + String.escapeSingleQuotes(searchTerm) + sq;
            }                  
            qryStr += ' ORDER BY Name';
            
            // limit rows
            qryStr += ' LIMIT ' + Math.min(limitRows, 500);
            System.debug('query=' + qryStr);
                
            // execute the query
            userSet = new ApexPages.StandardSetController(Database.getQueryLocator(qryStr));
            // set the page size
            userSet.setPageSize(pageSize);
                
        } catch (Exception ex) {
            // add error messages
            ApexPages.addMessages(ex);
            System.Debug(LoggingLevel.ERROR, ex.getMessage());
        }
    }
        
    /**
     * Gets the list of user objects from the current page in the resultset
     * @return the list of user objects
     */
    public List<UserWrapper> getUserList() {
        if (assigneeMatrixLevelStr == null) {
            return getUserListWithoutLevel();
        } else {
            return getUserListWithLevel();
        }
    }
        
    /**
     * Gets the list of user objects from the current page in the resultset
     * @return the list of user objects
     */
    private List<UserWrapper> getUserListWithoutLevel() {
        
        // get the product set
        ApexPages.StandardSetController userSet = getUserSet();
        
        // read records from the current page in the recordset
        if (userList == null && userSet != null) {
            userList = new List<UserWrapper>();
            
            for (User usr : (List<User>) userSet.getRecords()) {
                // Check if matrix level is > than current assignee's matrix level
                String matrixLevelStr = '';
                /*if ((usr.Apttus_Approval__Approval_Matrices__r != null) && (!usr.Apttus_Approval__Approval_Matrices__r.isEmpty())) {
                    matrixLevelStr = usr.Apttus_Approval__Approval_Matrices__r[0].Apttus_Approval__Approval_Level__c;
                }*/
                
                // add to the collection
                userList.add(new UserWrapper(usr, matrixLevelStr));             
            }
        }
        
        return userList;
    }
        
    /**
     * Gets the list of user objects from the current page in the resultset
     * @return the list of user objects
     */
    private List<UserWrapper> getUserListWithLevel() {
        
        // get the product set
        ApexPages.StandardSetController userSet = getUserSet();
        
        // read records from the current page in the recordset
        if (userList == null && userSet != null) {
            userList = new List<UserWrapper>();
            
            for (User usr : (List<User>) userSet.getRecords()) {
                // Check if matrix level is > than current assignee's matrix level
                String matrixLevelStr = usr.Apttus_Approval__Approval_Matrices__r[0].Apttus_Approval__Approval_Level__c;
                // add to the collection
                userList.add(new UserWrapper(usr, matrixLevelStr)); 
            }
        }
        
        return userList;
    }
        
    /**
     * Gets the user resultset
     * @return the user resultset
     */
    public  ApexPages.StandardSetController getUserSet() {
        
        // perform auto search (first time only)
        if (userSet == null) {
            doSearch();
        }
        
        return userSet;
    }
    
    /**
     * Checks if there are users in the resultset
     * @return <code>true</code> if there are users, <code<false</code> otherwise
     */
    public Boolean getHasUsers() {
        // get the user set
        ApexPages.StandardSetController userSet = getUserSet();
        
        return (userSet != null && userSet.getResultSize() > 0);
    } 
    
    /**
     * Checks if there are more records after the current page in the resultset
     * @return <code>true</code> if there are more records, <code>false</code> otherwise
     */
    public Boolean getHasNextPage() {
        return (userSet != null ? userSet.getHasNext() : false);
    }
    
    /**
     * Checks if there are more records before the current page in the resultset
     * @return <code>true</code> if there are more records, <code>false</code> otherwise
     */
    public Boolean getHasPreviousPage() {
        return (userSet != null ? userSet.getHasPrevious() : false);
    }
    
    /**
     * Gets the page number of the current page in the resultset
     * @return the page number
     */
    public Integer getCurrentPageNumber() {
        return (userSet != null ? userSet.getPageNumber() : 0);
    }
        
    /**
     * Gets the page size
     * @return the page size
     */
    public Integer getPageSize() {
        return pageSize;
    }
    
    /**
     * Sets the page size
     * @param pageSize the page size
     */
    public void setPageSize(Integer pageSize) {
        this.pageSize = pageSize;
    }
    
    /**
     * Gets the total number of pages in the resultset
     * @return the total number of pages
     */
    public Integer getTotalPages() {
        
        if (totalPages == null && userSet != null) {
            totalPages = userSet.getResultSize()/userSet.getPageSize();
            Integer remainder = Math.mod(userSet.getResultSize(), userSet.getPageSize());
            if (remainder > 0) {
                totalPages++;
            }
        }
        
        return (totalPages != null ? totalPages : 0);
    }
    
    /**
     * Positions the cursor to the first page in the resultset
     */
    public void firstPage() {
        
        if (userSet != null) {
            userSet.first();
            // reset current page
            userList = null;
        }
        
    }
    
    /**
     * Positions the cursor to the last page in the resultset
     */
    public void lastPage() {

        if (userSet != null) {
            userSet.last();
            // reset current page
            userList = null;
        }
    }
        
    /**
     * Positions the cursor to the previous page in the resultset
     */
    public void previousPage() {

        if (userSet != null) {
            userSet.previous();
            // reset current page
            userList = null;
        }
    }
        
    /**
     * Positions the cursor to the next page in the resultset
     */
    public void nextPage() {

        if (userSet != null) {
            userSet.next();
            // reset current page
            userList = null;
        }
    }
    
    /**
     * Gets approval request
     * @param requestId approval request identifier
     * @return approval request object
     */
    public static Apttus_Approval__Approval_Request__c getRequest(ID requestId) {
        
        // include necessary fields
        List<Apttus_Approval__Approval_Request__c> arList =  [select Id, Name, Apttus_Approval__Assigned_To_Type__c, Apttus_Approval__Assigned_To_Id__c 
                                            from Apttus_Approval__Approval_Request__c 
                                            where Id = :requestId];
        
        if ((arList == null) || (arList.isEmpty())) {
            return null;
        }
        return arList[0];
    }
    
    /**
     * Get matrix level number from the given level string
     * @param levelStr level string
     * @return level number
     */
    public static Integer getLevelNumber(String levelStr) {
        
        if (levelStr.contains('1')) {
            return 1;
            
        } else if (levelStr.contains('2')) {
            return 2;
            
        } else if (levelStr.contains('3')) {
            return 3;
            
        } else if (levelStr.contains('4')) {
            return 4;
            
        } else if (levelStr.contains('5')) {
            return 5;
            
        } else if (levelStr.contains('6')) {
            return 6;
            
        }   
        
        return 0;
        
    }
    /**
     * Get approval matrix for the given user
     * @param userId id of the business object owner
     * @return approval matrix object
     */
    public static Apttus_Approval__Approval_Matrix__c getMatrix(ID userId) {
        List<Apttus_Approval__Approval_Matrix__c> matrixList =  [select Apttus_Approval__User__c
                                                    , Apttus_Approval__Next_Level_Approver__c
                                                    , Name
                                                    , Apttus_Approval__Matrix_Owner__c
                                                    , Apttus_Approval__Is_Valid__c
                                                    , Apttus_Approval__Is_Active__c
                                                    , Id
                                                    , Apttus_Approval__Approval_Level__c 
                                                From Apttus_Approval__Approval_Matrix__c
                                                where Apttus_Approval__Is_Active__c = true
                                                    and Apttus_Approval__User__c = :userId];
                    
        if ((matrixList == null) || (matrixList.isEmpty())) {
            return null;
        }
        return matrixList[0];
    
    }
    
    /**
     * Checks if the given string value is null or empty.
     * @param strValue the string to check
     * @return <code>true</code> if the string value is null or empty, <code>false</code> otherwise
     */
    public static Boolean nullOrEmpty(String strValue) {
        // check if null or zero length string
        return (strValue == null || strValue.trim().length() == 0);
        
    }
    /**
    *  Converts multi-select from list separated by ;
    *  to a list separated by ','
    */
    
    public static String fixMultiSelect(String currentStr)
    {
        String sq = '\'';
    
        String strFind = ';';
        String strReplace = sq + ',' + sq;
        String newStr = currentStr.replaceAll(strFind, strReplace);
        return newStr;
    }
    
    /**
     * User wrapper class which includes User's approval matrix level
     */
    public class UserWrapper {
        // user object
        public User user {get; private set;}
        // user's approval matrix level
        public String approverLevel {get; private set;}
        
        // Prevent empty instantiation
        private UserWrapper() {
            
        }
        /**
         * Constructor with user object
         */
        public UserWrapper(User user, String approverLevel) {
            this();
            this.user = user;
            this.approverLevel = approverLevel;
        }
        
    }
}