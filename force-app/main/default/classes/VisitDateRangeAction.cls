public class VisitDateRangeAction {
    
    @InvocableMethod(label='Calculate Visit Date Range' description='Calculate start and end dates based on time period')
    public static List<DateRangeResult> calculateDateRange(List<String> timePeriods) {
        List<DateRangeResult> results = new List<DateRangeResult>();
        
        for (String timePeriod : timePeriods) {
            DateRangeResult result = new DateRangeResult();
            result.timePeriod = timePeriod;
            
            DateTime now = DateTime.now();
            DateTime startDate, endDate;
            
            if (timePeriod == 'Today') {
                // Today: Start of day to end of day
                startDate = DateTime.newInstance(now.date(), Time.newInstance(0, 0, 0, 0));
                endDate = DateTime.newInstance(now.date(), Time.newInstance(23, 59, 59, 999));
            } else if (timePeriod == 'Tomorrow') {
                // Tomorrow: Start of tomorrow to end of tomorrow
                Date tomorrow = now.date().addDays(1);
                startDate = DateTime.newInstance(tomorrow, Time.newInstance(0, 0, 0, 0));
                endDate = DateTime.newInstance(tomorrow, Time.newInstance(23, 59, 59, 999));
            } else if (timePeriod == 'This Week') {
                // This Week: Start of current week (Monday) to end of current week (Sunday)
                Date startOfWeek = now.date().toStartOfWeek();
                Date endOfWeek = startOfWeek.addDays(6);
                startDate = DateTime.newInstance(startOfWeek, Time.newInstance(0, 0, 0, 0));
                endDate = DateTime.newInstance(endOfWeek, Time.newInstance(23, 59, 59, 999));
            } else if (timePeriod == 'Next Week') {
                // Next Week: Start of next week (Monday) to end of next week (Sunday)
                Date startOfNextWeek = now.date().toStartOfWeek().addDays(7);
                Date endOfNextWeek = startOfNextWeek.addDays(6);
                startDate = DateTime.newInstance(startOfNextWeek, Time.newInstance(0, 0, 0, 0));
                endDate = DateTime.newInstance(endOfNextWeek, Time.newInstance(23, 59, 59, 999));
            } else if (timePeriod == 'This Month') {
                // This Month: Start of current month to end of current month
                Date startOfMonth = Date.newInstance(now.year(), now.month(), 1);
                Date endOfMonth = startOfMonth.addMonths(1).addDays(-1);
                startDate = DateTime.newInstance(startOfMonth, Time.newInstance(0, 0, 0, 0));
                endDate = DateTime.newInstance(endOfMonth, Time.newInstance(23, 59, 59, 999));
            } else if (timePeriod == 'Next Month') {
                // Next Month: Start of next month to end of next month
                Date startOfNextMonth = Date.newInstance(now.year(), now.month(), 1).addMonths(1);
                Date endOfNextMonth = startOfNextMonth.addMonths(1).addDays(-1);
                startDate = DateTime.newInstance(startOfNextMonth, Time.newInstance(0, 0, 0, 0));
                endDate = DateTime.newInstance(endOfNextMonth, Time.newInstance(23, 59, 59, 999));
            } else {
                // Default to Today if unknown time period
                startDate = DateTime.newInstance(now.date(), Time.newInstance(0, 0, 0, 0));
                endDate = DateTime.newInstance(now.date(), Time.newInstance(23, 59, 59, 999));
            }
            
            result.startDate = startDate;
            result.endDate = endDate;
            results.add(result);
        }
        
        return results;
    }
    
    public class DateRangeResult {
        @InvocableVariable(required=true)
        public DateTime startDate;
        
        @InvocableVariable(required=true)
        public DateTime endDate;
        
        @InvocableVariable(required=true)
        public String timePeriod;
    }
}