package com.pathfinder {
	
	public class EHeuristic
	{
		public static const PRODUCT:String = 'PRODUCT';
		public static const DIAGONAL:String = 'DIAGONAL';
		public static const EUCLIDIAN:String = 'EUCLIDIAN';
		public static const MANHATTAN:String = 'MANHATTAN';
		/**
		 * pretty & accurate (the allrounder)
		 */
		//DIAGONAL;
		/**
		 * fast and pretty but might not be shortest (the beauty) - *the default*
		 */
		//PRODUCT;
		/**
		 * shortest path but slow (the brainiac)
		 */
		//EUCLIDIAN;
		/**
		 * fastest, ugliest, least accurate (the athlete)
		 */
		//MANHATTAN;
	}
	
}

/**
 * @author Statm	https://github.com/statm/haxe-astar
 * @author Robert Fell
 */

