# LSC4CE Agentforce Solutions - Troubleshooting Guide

## Common Issues and Solutions

### 1. Deployment Issues

#### Issue: "Flow not found" during deployment
**Symptoms**: Deployment fails with flow-related errors
**Solutions**:
- Verify all flow files are present in `force-app/main/default/flows/`
- Check flow metadata files have correct API version (65.0)
- Ensure flows are not already deployed with different versions

#### Issue: "Apex class compilation errors"
**Symptoms**: Apex classes fail to compile
**Solutions**:
- Check for missing dependencies (other classes, objects)
- Verify API version compatibility
- Review debug logs for specific compilation errors

### 2. Agentforce Configuration Issues

#### Issue: "Action not found in topic"
**Symptoms**: Agentforce actions don't appear in topics
**Solutions**:
- Verify action is activated in Agentforce
- Check action is properly added to the topic
- Ensure action configuration is correct

#### Issue: "Prompt template not responding"
**Symptoms**: Prompt templates return empty or error responses
**Solutions**:
- Verify prompt template is activated
- Check template variables are properly mapped
- Review template content for syntax errors

### 3. Data Access Issues

#### Issue: "No territory assigned to user"
**Symptoms**: Users get territory-related errors
**Solutions**:
- Verify user has Territory2 assignment
- Check UserTerritory2Association records
- Ensure territory is active and properly configured

#### Issue: "No visits found"
**Symptoms**: Visit queries return empty results
**Solutions**:
- Check Visit records exist for the user's territory
- Verify date ranges are correct
- Ensure user has access to Visit records

### 4. Flow Execution Issues

#### Issue: "Flow execution failed"
**Symptoms**: Flows fail to execute or return errors
**Solutions**:
- Check Flow execution logs in Setup → Process Automation → Flows
- Verify all required input variables are provided
- Ensure Flow is activated

#### Issue: "Apex action not available in Flow"
**Symptoms**: Apex actions don't appear in Flow Builder
**Solutions**:
- Verify Apex class has @InvocableMethod annotation
- Check method signature matches Flow requirements
- Ensure class is deployed and active

### 5. Performance Issues

#### Issue: "Query timeout"
**Symptoms**: SOQL queries exceed time limits
**Solutions**:
- Optimize queries with appropriate filters
- Use indexed fields in WHERE clauses
- Consider breaking large queries into smaller chunks

#### Issue: "Heap size exceeded"
**Symptoms**: Apex execution hits memory limits
**Solutions**:
- Reduce data processing in single transaction
- Use batch processing for large datasets
- Optimize data structures and variables

## Debug Steps

### 1. Check Debug Logs
```bash
sf apex log tail --target-org your-org
```

### 2. Verify User Permissions
1. Navigate to Setup → Users
2. Check user's permission sets and profiles
3. Verify territory assignments

### 3. Test Individual Components
1. Test Apex classes directly in Developer Console
2. Test Flows individually in Flow Builder
3. Test Agentforce actions in isolation

### 4. Check Data Availability
1. Verify required objects and records exist
2. Check data relationships and integrity
3. Ensure proper data access permissions

## Error Messages Reference

### Apex Errors
- `System.QueryException`: SOQL query issues
- `System.DmlException`: Data manipulation errors
- `System.LimitException`: Governor limit exceeded
- `System.NullPointerException`: Null reference errors

### Flow Errors
- `FLOW_ELEMENT_ERROR`: Flow element execution failed
- `FLOW_INTERVIEW_ERROR`: Flow interview failed
- `FLOW_VALIDATION_ERROR`: Flow validation failed

### Agentforce Errors
- `AGENTFORCE_ACTION_ERROR`: Action execution failed
- `AGENTFORCE_TOPIC_ERROR`: Topic processing failed
- `AGENTFORCE_PROMPT_ERROR`: Prompt template error

## Recovery Procedures

### 1. Rollback Deployment
```bash
sf project deploy cancel --target-org your-org --job-id JOB_ID
```

### 2. Restore Previous Version
1. Navigate to Setup → Deploy → Deployment Status
2. Find the previous successful deployment
3. Rollback to that version

### 3. Reset Agentforce Configuration
1. Deactivate all Agentforce components
2. Reconfigure from scratch using documentation
3. Test each component individually

## Prevention Best Practices

### 1. Testing
- Always test in sandbox first
- Run comprehensive test suites
- Test with different user profiles and territories

### 2. Monitoring
- Set up monitoring for key metrics
- Track performance and usage patterns
- Monitor error rates and user feedback

### 3. Documentation
- Keep setup guides updated
- Document any customizations
- Maintain troubleshooting knowledge base

## Getting Help

### 1. Internal Resources
- Check existing documentation
- Review setup guides and API reference
- Consult with LSC4CE team members

### 2. Salesforce Resources
- Salesforce Help & Training
- Trailhead modules
- Salesforce Developer Community

### 3. Escalation
- Contact LSC4CE team lead
- Escalate to Salesforce support if needed
- Document issues for future reference

