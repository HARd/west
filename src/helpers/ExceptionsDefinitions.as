package helpers 
{
	public class ExceptionsDefinitions 
	{
		public static var ITEMS:Array = 
		[
			[738,749,797,815,816,817,935,980,981,982,1002,1012,1193,1302,1845,1868,1658,1969,2201,2371,2641,2642,2732],
			[738, 749, 815, 816, 817, 797, 835, 1002, 1845, 1868, 1658, 1969, 2201],
			[935, 980, 981, 982, 1012, 1193, 1302, 1658, 2201, 2371, 2641, 2642, 2732],
			[797, 815, 816, 817, 935, 980, 981, 982, 1012, 1193, 1302, 1845, 1868, 1658, 1969, 2013, 2201, 2371, 2641, 2642, 2732],
			[668, 738, 749, 1010],
			[797,815,816,817,935,980,981,982,1004,1012,1193,1302,1444,1666,1845,1868,1658,1969,2013,2201,2371,2641,2642,2732]
		];
		
		public static var TYPES:Array =
		[
			['Garden', 'Building', 'Technological', 'Rbuilding', 'Tribute'],
			['Resource', 'Decor', 'Golden', 'Plant', 'Tree', 'Animal'],
			['Golden', 'Gamble', 'Walkgolden'],
			['Golden', 'Walkgolden'],
			['Goldbox'],
			['Gamble'],
			['Golden', 'Thimbles', 'Gamble', 'Fatman'],
			['Collection', 'Pack']
		];
		
		public static function CheckItem(exceptionID:int, ID:int):Boolean
		{
			return (ITEMS[exceptionID].indexOf(ID) > -1)? true:false;
		}
		
		public static function CheckType(exceptionID:int, ID:int):Boolean
		{
			return (TYPES[exceptionID].indexOf(ID) > -1)? true:false;
		}
		
		public function ExceptionsDefinitions(blocker:Blocker) 
		{
		}
	}

}

class Blocker
{
	
}