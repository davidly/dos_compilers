main()
{   int    Score, Avg_Score, No_of_Students;
    long   Total_Score;
    prompt1();
    No_of_Students = 0;
    Total_Score = 0;
    prompt2();
    scanf("%d", &Score);
    while (Score != -1) {
        Total_Score = Total_Score + Score;
        ++No_of_Students;
        prompt2();
        scanf("%d", &Score);
    }
    printf("You Entered Scores for %d Students.\n",
        No_of_Students);
    if (No_of_Students > 0) {
        Avg_Score = Total_Score/No_of_Students;
        printf("Average Score was %d.", Avg_Score);
    }
}

prompt1()
{
    Printf("*** Program to Compute Average Test Score ***\n");
    Printf("     A Test Score of -1 Terminates Input\n");
}

prompt2()
{
    printf("Enter Test Score: ");
}

