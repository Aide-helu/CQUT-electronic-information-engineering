#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
void fun(int a,int b,long *c)
{



}

main()     /*������*/
{  int a,b;long c;
   system("cls");
   printf("Input a,b:");
   scanf("%d%d",&a,&b);
   fun(a,b,&c);
   printf("The result is: %ld\n",c);
   NONO();
}
NONO (  )
{/* ���������ڴ��ļ����������ݣ����ú�����������ݣ��ر��ļ��� */
  FILE *rf, *wf ;
  int i, a,b ; long c ;

  rf = fopen("in8.dat", "r") ;
  wf = fopen("bd02.dat","w") ;
  for(i = 0 ; i < 10 ; i++) {
    fscanf(rf, "%d,%d", &a, &b) ;
    fun(a, b, &c) ;
    fprintf(wf, "a=%d,b=%d,c=%ld\n", a, b, c) ;
  }
  fclose(rf) ;
  fclose(wf) ;
}
   
