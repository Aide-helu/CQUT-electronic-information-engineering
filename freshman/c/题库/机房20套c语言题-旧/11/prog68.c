#include <stdio.h>
#include <conio.h>
void fun(char *a)
{


}

main()
{   char s[81];
    printf("Enter a string:\n");gets(s);
    fun(s);
    printf("The string after deleted:\n");puts(s);
    NONO();
}
NONO( )
{/* ���ڴ˺����ڴ��ļ�������������ݣ����� fun ������
    ������ݣ��ر��ļ��� */
   char s[81];
   int i;
   FILE  *rf,*wf;
   rf = fopen("b36.in","r");
   wf = fopen("a36.out", "w") ;
   for (i=0;i<4;i++)
   {fscanf(rf,"%s",s);
    fun(s);
   fprintf(wf,"%s\n",s);
   }
   fclose(rf);
   fclose(wf) ;
 }
