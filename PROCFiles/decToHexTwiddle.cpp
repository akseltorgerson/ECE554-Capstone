#include <iostream>
#include <fstream>
#include <string>
#include <cmath>
#include <iomanip>
using namespace std;

// Driver program to test above function
int main()
{
	ifstream myfile;
	ofstream outputFile;
	myfile.open("twiddleFactors.txt");
	outputFile.open("twiddleHex.mem");

	if (myfile.is_open() && outputFile.is_open())
	{
		std::string tp;
		int count = 0;
		while (getline(myfile, tp))
		{
			bool negative = tp.at(0) == '-';
			string hexValue = "";
			double value = std::stod(tp);
			double intDouble = 0.0;
			int integerVal = 0;

			value = value * 16 * 16 * 16 * 16;

			std::modf(value, &intDouble);
			integerVal = static_cast<int>(intDouble);

			/**for(int i = 0; i < 8; i++) {
		int intermediate = integerVal % 16;
		integerVal = integerVal / 16;

		if (negative && intermediate != 0) {
		    intermediate += 16;
		}

		std::stringstream stream;

		if(intermediate < 10){
		    stream << intermediate;
		} else {
		    switch(intermediate) {
			    case 10: 
				    stream << "a";
				    break;
			    case 11:
				    stream << "b";
				    break;
			    case 12:
				    stream << "c";
				    break;
			    case 13:
				    stream << "d";
				    break;
			    case 14:
				    stream << "e";
				    break;
			    case 15:
				    stream << "f";
				    break;
		    }
		}
		
		hexValue = stream.str() + hexValue;
	    }*/

			//cout << hexValue << '\n';

		std:
			stringstream stream;
			stream << std::hex << integerVal;

			string output = stream.str();

			if (output.length() != 8)
			{
				for (int k = output.length(); k < 8; k++)
				{
					output = "0" + output;
				}
			}

			outputFile << output << '\n';
		}
	}

	myfile.close();
	outputFile.close();
}
