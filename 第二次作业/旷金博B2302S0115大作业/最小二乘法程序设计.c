#include<stdio.h>
#include<math.h>
#define X 50
#define Y 50
float x[X],y[Y];
int n;//输入的数据总组数即坐标的总个数
void init();//初始化并输入相关数据
void confrim();//确认输入的数据
void deal();//根据输入的坐标点计算出拟合曲线
void modify();//用于修改输错的相应坐标这样可以避免一些数据重新输入
void main()
{
	
	int select;
	system("color f1");//dos命令使界面变颜色
	init();//
	confrim();
	printf("请选择要拟合成几次多项式（提示：如果是一次函数就输入1二次函数就输入2）：");
	scanf("%d",&select);//输入你要选择拟合的函数的次数
	deal(select);
}

void init()//初始化并输入相关数据
{
	int i;
	printf ("\n*********************************************************\n");
	printf ("\n欢迎使用最小二乘法数据处理程序\n");
	printf ("\n请输入您要处理的数据的组数(提示：程序定义一对x,y值为一组数据):");
	
	while(1)
	{
		scanf("%d",&n);
		if(n<=1)
		{
			printf("\n理的数据的组数不能小于或等于1");
			printf ("\n请重新输入您要处理的数据的组数:");
		}
		
		else if(n>50)
		{
			printf ("\n对不起，本程序暂时无法处理50组以上的数据");
			printf ("\n请重新输入您要处理的数据的组数:");
		} 
		else break;
	}
	
	for (i=0;i<n;i++)//输入相应坐标点将其存到数组里
	{
		printf ("\n请输入第%d个x的值x%d=",i+1,i+1);
		scanf ("%f",&x[i]);
		printf ("\n请输入对应的y的值:y%d=",i+1);
		scanf ("%f",&y[i]);
	}
	system("color f2");//
	system("cls");//清屏
}

void deal(int select)//采用克莱默法则求解方程
{
	int i;
	float a0,a1,a2,temp,temp0,temp1,temp2;
	float sy=0,sx=0,sxx=0,syy=0,sxy=0,sxxy=0,sxxx=0,sxxxx=0;//定义相关变量
	for(i=0;i<n;i++)
	{
		sx+=x[i];//计算xi的和
		sy+=y[i];//计算yi的和
		sxx+=x[i]*x[i];//计算xi的平方的和
		sxxx+=pow(x[i],3);//计算xi的立方的和
		sxxxx+=pow(x[i],4);//计算xi的4次方的和
		sxy+=x[i]*y[i];//计算xi乘yi的的和
		sxxy+=x[i]*x[i]*y[i];//计算xi平方乘yi的和
	}
	temp=n*sxx-sx*sx;//方程的系数行列式
	temp0=sy*sxx-sx*sxy;
	temp1=n*sxy-sy*sx;
	a0=temp0/temp;
	a1=temp1/temp;
	if(select==1)
	{
		printf("经最小二乘法拟合得到的一元线性方程为:\n"); 
		printf("f(x)=%3.3fx+%3.3f\n",a1,a0); 
				system("pause");
	}
	temp=n*(sxx*sxxxx-sxxx*sxxx)-sx*(sx*sxxxx-sxx*sxxx)//方程的系数行列式
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
		printf("经最小二乘法拟合得到的二次近似方程为:\n"); 
		printf("f(x)=%3.3fx2+%3.3fx+%3.3f\n",a2,a1,a0); 
		system("pause");
	}
	
}
void modify()//修改输错的相应坐标

{  
	int z;
	char flag;
	while(1)
	{
		printf("请输入你要修改的是第几组数据：");
		scanf("%d",&z);
		printf ("\n请输入你要修改的第%d个x的值x%d=",z,z);
		scanf ("%f",&x[z-1]);
		printf ("\n请输入你要修改的对应的y的值:y%d=",z);
		scanf ("%f",&y[z-1]);
		printf("是否继续修改数据是Y否N：");
		getchar();
		scanf("%c",&flag);
		if(flag=='N'||flag=='n')
			break;
	}
	system("cls");//清屏
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
			printf ("请输入第%d个x的值x%d=",i+1,i+1);
			printf ("%f",x[i]);
			printf ("  输入对应的y的值:y%d=",i+1);
			
			printf("%f",y[i]);
			printf("\n");
		}
		printf("确认你输入的数据是Y否N(即重新输入)修改M:");
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
