#include <iostream>
#include <vector>

struct Node {
    int id;
    int degree;
};

int main() {
    const int totalNodes = 500;
    const int minDegree = 1000;

    // ����ڵ�����
    std::vector<Node> nodes(totalNodes);

    // ��ʼ���ڵ㣬����ÿ���ڵ㶼����ͬ�����ɶ�
    for (int i = 0; i < totalNodes; ++i) {
        nodes[i].id = i + 1;
        nodes[i].degree = minDegree / 10; // ����ÿ���ڵ�����ɶ��� 100
    }

    // �����ܵ����ɶ�
    int totalDegrees = minDegree * totalNodes / 10;

    // �������ɶ�ʹÿ���ڵ���ܺʹ��� 1000
    for (int i = 0; i < totalNodes; ++i) {
        while (nodes[i].degree * 10 <= minDegree) {
            for (int j = 0; j < totalNodes; ++j) {
                if (i != j && nodes[j].degree > minDegree / 10) {
                    nodes[i].degree++;
                    nodes[j].degree--;
                    break;
                }
            }
        }
    }

    // ���ÿ���ڵ��ID�����ɶ�
    for (int i = 0; i < totalNodes; ++i) {
        std::cout << "Node " << nodes[i].id << ": Degree " << nodes[i].degree * 10 << std::endl;
    }

    // ��֤�ܵ����ɶ��Ƿ���� 1000
    int sum = 0;
    for (int i = 0; i < totalNodes; ++i) {
        sum += nodes[i].degree * 10;
    }
    std::cout << "Total degrees: " << sum << std::endl;

    return 0;
}
