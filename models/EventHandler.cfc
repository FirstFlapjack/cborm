﻿/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Generic Hibernate Event Handler that ties to the ColdBox proxy for ColdBox Operations.
 * This is just a base class you can inherit from to give you access to your ColdBox
 * Application and the CF9 ORM event handler methods. Then you just need to
 * use a la carte.
 *
 * We also execute interception points that match the ORM events so you can eaisly
 * chain ORM interceptions.
 *
 */
component extends="coldbox.system.remote.ColdboxProxy" implements="CFIDE.orm.IEventHandler"{

	/**
	* preLoad called by hibernate which in turn announces a coldbox interception: ORMPreLoad
	*/
	public void function preLoad( any entity ){
		announceInterception( "ORMPreLoad", { entity = arguments.entity } );
	}

	/**
	* postLoad called by hibernate which in turn announces a coldbox interception: ORMPostLoad
	*/
	public void function postLoad( any entity ){
		var args = { entity=arguments.entity, entityName="" };

		// Short-cut discovery via ActiveEntity
		if( structKeyExists( arguments.entity, "getEntityName" ) ){
			args.entityName = arguments.entity.getEntityName();
		} else {
			// it must be in session.
			args.entityName = ormGetSession().getEntityName( arguments.entity );
		}

		processEntityInjection( args.entityName, args.entity );

		announceInterception( "ORMPostLoad", args );
	}

	/**
	* postDelete called by hibernate which in turn announces a coldbox interception: ORMPostDelete
	*/
	public void function postDelete( any entity ){
		announceInterception( "ORMPostDelete", { entity=arguments.entity } );
	}

	/**
	* preDelete called by hibernate which in turn announces a coldbox interception: ORMPreDelete
	*/
	public void function preDelete( any entity) {
		announceInterception( "ORMPreDelete", { entity=arguments.entity } );
	}

	/**
	* preUpdate called by hibernate which in turn announces a coldbox interception: ORMPreUpdate
	*/
	public void function preUpdate( any entity, Struct oldData={}){
		announceInterception( "ORMPreUpdate", { entity=arguments.entity ,  oldData=arguments.oldData});
	}

	/**
	* postUpdate called by hibernate which in turn announces a coldbox interception: ORMPostUpdate
	*/
	public void function postUpdate( any entity ){
		announceInterception( "ORMPostUpdate", { entity=arguments.entity } );
	}

	/**
	* preInsert called by hibernate which in turn announces a coldbox interception: ORMPreInsert
	*/
	public void function preInsert( any entity ){
		announceInterception( "ORMPreInsert", { entity=arguments.entity } );
	}

	/**
	* postInsert called by hibernate which in turn announces a coldbox interception: ORMPostInsert
	*/
	public void function postInsert( any entity ){
		announceInterception( "ORMPostInsert", { entity=arguments.entity } );
	}

	/**
	* preSave called by ColdBox Base service before save() calls
	*/
	public void function preSave( any entity ){
		announceInterception( "ORMPreSave", { entity=arguments.entity } );
	}

	/**
	* postSave called by ColdBox Base service after transaction commit or rollback via the save() method
	*/
	public void function postSave( any entity ){
		announceInterception( "ORMPostSave", { entity=arguments.entity } );
	}

	/**
    * Called before the session is flushed.
    */
    public void function preFlush( any entities){
    	announceInterception( "ORMPreFlush", { entities=arguments.entities } );
    }

    /**
    * Called after the session is flushed.
    */
    public void function postFlush( any entities){
    	announceInterception( "ORMPostFlush", { entities=arguments.entities } );
    }

    /**
	* postNew called by ColdBox which in turn announces a coldbox interception: ORMPostNew
	*/
	public void function postNew( any entity, any entityName ){
		var args = { entity=arguments.entity, entityName="" };

		// Short-cut discovery via ActiveEntity
		if( structKeyExists( arguments.entity, "getEntityName" ) ){
			args.entityName = arguments.entity.getEntityName();
		} else {
			// Long Discovery
			var md = getMetadata( arguments.entity );
			args.entityName = ( md.keyExists( "entityName" ) ? md.entityName : listLast( md.name, "." ) );
		}

		processEntityInjection( args.entityName, args.entity );

		announceInterception( "ORMPostNew", args );
	}

	/**
	* Get the system Event Manager
	*/
	public any function getEventManager(){
		return getWireBox().getEventManager();
	}

	/********************************* PRIVATE *********************************/

	/**
	 * process entity injection
	 *
	 * @entityName the entity to process, we use hash codes to identify builders
	 * @entity The entity object
	 */
	private function processEntityInjection( required entityName, required entity ){
		var ormSettings 	= getController().getConfigSettings().modules[ "cborm" ].settings;
		var injectorInclude = ormSettings.injection.include;
		var injectorExclude = ormSettings.injection.exclude;

		// Enabled?
		if( NOT ormSettings.injection.enabled ){
			return;
		}

		// Include,Exclude?
		if( ( len( injectorInclude ) AND listContainsNoCase( injectorInclude, entityName ) )
		    OR
			( len( injectorExclude ) AND NOT listContainsNoCase( injectorExclude, entityName ) )
			OR
			( NOT len( injectorInclude ) AND NOT len( injectorExclude ) )
		){
			// Process DI
			getWireBox().autowire(
				target 		= entity,
				targetID 	= "ORMEntity-#entityName#"
			);
		}
	}

}