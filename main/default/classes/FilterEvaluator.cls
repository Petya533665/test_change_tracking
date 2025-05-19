public with sharing class FilterEvaluator {

    //private static Boolean orJoin(String x, String y) { return evaluate(x) || evaluate(y); }
    //private static Boolean andJoin(String x, String y) { return evaluate(x) && evaluate(y); }
    private static Boolean orJoin(String[] xy) { return evaluate(xy[0]) || evaluate(xy[1]); }
    private static Boolean andJoin(String[] xy) { return evaluate(xy[0]) && evaluate(xy[1]); }
    private static Boolean isSimpleExpression(String x) { return x == 'true' || x == 'false'; }

    private static String simplify(String x) {
        x = x.trim();
        while (x.contains('('))
        {
            String sub = x.substringAfterLast('(').substringBefore(')');
            x = x.replace('(' + sub + ')', String.valueOf(evaluate(sub)));
        }
        return x;
    }

    public static String substituteValues(String expression, Boolean[] values) {
        String[] arguments = expression.split(' ');
        for(String arg : arguments) {
            try {
                Integer index = Integer.valueOf(arg.replaceAll('[^0-9]', ''));
                expression = expression.replaceAll(String.valueOf(index), String.valueOf(values[index - 1]));
            } catch(Exception e) {}
        }
        return expression;
    }

    public static String substituteValues(String expression, String[] values) {
        String[] arguments = expression.split(' ');
        for(String arg : arguments) {
            try {
                Integer index = Integer.valueOf(arg.replaceAll('[^0-9]', ''));
                expression = expression.replaceAll(String.valueOf(index), values[index - 1]);
            } catch(Exception e) {}
        }
        return expression;
    }

    public static Boolean evaluate(String x, Boolean[] values) {
        x = substituteValues(x, values);
        return evaluate(x);
    }

    public static Boolean evaluate(String x) {
        x = simplify(x);
        if (!isSimpleExpression(x))
        {
            if (x.contains('AND')) return andJoin(x.split('AND', 2));
            if (x.contains('OR')) return orJoin(x.split('OR', 2));
            if (x.startsWith('!')) return !evaluate(x.substring(1));
        }
        return Boolean.valueOf(x);
    }
}