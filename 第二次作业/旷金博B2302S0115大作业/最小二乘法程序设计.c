#include<stdio.h>
#include<math.h>
#define X 50
#define Y 50
float x[X],y[Y];
int n;//�����������������������ܸ���
void init();//��ʼ���������������
void confrim();//ȷ�����������
void deal();//�������������������������
void modify();//�����޸�������Ӧ�����������Ա���һЩ������������
void main()
{
	
	int select;
	system("color f1");//dos����ʹ�������ɫ
	init();//
	confrim();
	printf("��ѡ��Ҫ��ϳɼ��ζ���ʽ����ʾ�������һ�κ���������1���κ���������2����");
	scanf("%d",&select);//������Ҫѡ����ϵĺ����Ĵ���
	deal(select);
}

void init()//��ʼ���������������
{
	int i;
	printf ("\n*********************************************************\n");
	printf ("\n��ӭʹ����С���˷����ݴ������\n");
	printf ("\n��������Ҫ��������ݵ�����(��ʾ��������һ��x,yֵΪһ������):");
	
	while(1)
	{
		scanf("%d",&n);
		if(n<=1)
		{
			printf("\n������ݵ���������С�ڻ����1");
			printf ("\n������������Ҫ��������ݵ�����:");
		}
		
		else if(n>50)
		{
			printf ("\n�Բ��𣬱�������ʱ�޷�����50�����ϵ�����");
			printf ("\n������������Ҫ��������ݵ�����:");
		} 
		else break;
	}
	
	for (i=0;i<n;i++)//������Ӧ����㽫��浽������
	{
		printf ("\n�������%d��x��ֵx%d=",i+1,i+1);
		scanf ("%f",&x[i]);
		printf ("\n�������Ӧ��y��ֵ:y%d=",i+1);
		scanf ("%f",&y[i]);
	}
	system("color f2");//
	system("cls");//����
}

void deal(int select)//���ÿ���Ĭ������ⷽ��
{
	int i;
	float a0,a1,a2,temp,temp0,temp1,temp2;
	float sy=0,sx=0,sxx=0,syy=0,sxy=0,sxxy=0,sxxx=0,sxxxx=0;//������ر���
	for(i=0;i<n;i++)
	{
		sx+=x[i];//����xi�ĺ�
		sy+=y[i];//����yi�ĺ�
		sxx+=x[i]*x[i];//����xi��ƽ���ĺ�
		sxxx+=pow(x[i],3);//����xi�������ĺ�
		sxxxx+=pow(x[i],4);//����xi��4�η��ĺ�
		sxy+=x[i]*y[i];//����xi��yi�ĵĺ�
		sxxy+=x[i]*x[i]*y[i];//����xiƽ����yi�ĺ�
	}
	temp=n*sxx-sx*sx;//���̵�ϵ������ʽ
	temp0=sy*sxx-sx*sxy;
	temp1=n*sxy-sy*sx;
	a0=temp0/temp;
	a1=temp1/temp;
	if(select==1)
	{
		printf("����С���˷���ϵõ���һԪ���Է���Ϊ:\n"); 
		printf("f(x)=%3.3fx+%3.3f\n",a1,a0); 
				system("pause");
	}
	temp=n*(sxx*sxxxx-sxxx*sxxx)-sx*(sx*sxxxx-sxx*sxxx)//���̵�ϵ������ʽ
		+sxx*(sx*sxxx-sxx*sxx);
	temp0=sy*(sxx*sxxxx-sxxx*sxxx)-sxy*(sx*sxxxx-sxx*sxxx)
		+sxxy*(sx*sxxx-sxx*sxx);
	temp1=n*(sxy*sxxxx-sxxy*sxxx)-sx*(sy*sxxxx-sxx*sxxy)
		+sxx*(sy*sxxx-sxy*sxx);
	temp2=n*(sxx*sxxy-sxy*sxxx)-sx*(sx*sxxy-sy*sxxx)
		+sxx*(sx*sxy-sy*sxx);
	a0=temp0/temp;
	a1=temp1/temp;
	a2=temp2/temp;
	if(select==2)
	{
		printf("����С���˷���ϵõ��Ķ��ν��Ʒ���Ϊ:\n"); 
		printf("f(x)=%3.3fx2+%3.3fx+%3.3f\n",a2,a1,a0); 
		system("pause");
	}
	
}
void modify()//�޸�������Ӧ����

{  
	int z;
	char flag;
	while(1)
	{
		printf("��������Ҫ�޸ĵ��ǵڼ������ݣ�");
		scanf("%d",&z);
		printf ("\n��������Ҫ�޸ĵĵ�%d��x��ֵx%d=",z,z);
		scanf ("%f",&x[z-1]);
		printf ("\n��������Ҫ�޸ĵĶ�Ӧ��y��ֵ:y%d=",z);
		scanf ("%f",&y[z-1]);
		printf("�Ƿ�����޸�������Y��N��");
		getchar();
		scanf("%c",&flag);
		if(flag=='N'||flag=='n')
			break;
	}
	system("cls");//����
	confrim();
}
void confrim()
{
	char flag;
	int i;
	while(1)
	{
		for(i=0;i<n;i++)
		{
			printf ("�������%d��x��ֵx%d=",i+1,i+1);
			printf ("%f",x[i]);
			printf ("  �����Ӧ��y��ֵ:y%d=",i+1);
			
			printf("%f",y[i]);
			printf("\n");
		}
		printf("ȷ���������������Y��N(����������)�޸�M:");
		getchar();
		scanf("%c",&flag);
		if(flag=='y'||flag=='Y')
			break;
		else if(flag=='n'||flag=='N')
			init();
		else 
		{
			modify();
			break;
		}
	}	
}
