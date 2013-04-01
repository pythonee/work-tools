BEGIN{
	max_conn = -1;
	min_conn = -1;
	avg_conn = -1;	
	max_query = -1;
	min_query = -1;	
	tps = -1;
	total_queries = -1;
}

$0{
	if (NR == 2) {
		max_conn = substr($2,5);
		min_conn = substr($3,5);
		avg_conn = $5;
	} 
	else if(NR==4){
		total_queries = $2;
		max_query = $3;
		min_query = $4;		
		tps = $5;
	}
}

END {
	printf("%s %s %s %s %s %s %s\n", total_queries, max_query, min_query, max_conn, min_conn, avg_conn, tps );
}
